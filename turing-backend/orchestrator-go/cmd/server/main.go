package main

import (
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/app"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/config"
	"google.golang.org/grpc"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	orchestrator, err := app.New(cfg)
	if err != nil {
		return err
	}
	defer orchestrator.Stop()

	publicLis, err := net.Listen("tcp", fmt.Sprintf(":%d", cfg.PublicPort))
	if err != nil {
		return fmt.Errorf("listen public: %w", err)
	}
	internalLis, err := net.Listen("tcp", fmt.Sprintf(":%d", cfg.InternalPort))
	if err != nil {
		_ = publicLis.Close()
		return fmt.Errorf("listen internal: %w", err)
	}

	errCh := make(chan error, 2)
	go serve(errCh, "public", orchestrator.PublicServer, publicLis)
	go serve(errCh, "internal", orchestrator.InternalServer, internalLis)

	signalCh := make(chan os.Signal, 1)
	signal.Notify(signalCh, syscall.SIGINT, syscall.SIGTERM)
	defer signal.Stop(signalCh)

	select {
	case sig := <-signalCh:
		log.Printf("received %s, shutting down", sig)
		orchestrator.Stop()
		return nil
	case err := <-errCh:
		orchestrator.Stop()
		return err
	}
}

func serve(errCh chan<- error, name string, server *grpc.Server, lis net.Listener) {
	if err := server.Serve(lis); err != nil && !errors.Is(err, grpc.ErrServerStopped) {
		errCh <- fmt.Errorf("serve %s: %w", name, err)
	}
}
