package events

import (
	"testing"
	"time"
)

func TestBusPublishesOnlyMatchingSessionAndUnsubscribes(t *testing.T) {
	bus := NewBus(8)
	ch, unsubscribe := bus.Subscribe("sess_1")
	bus.Publish(Event{SessionID: "sess_2", Sequence: 1})
	select {
	case got := <-ch:
		t.Fatalf("unexpected event: %+v", got)
	default:
	}
	bus.Publish(Event{SessionID: "sess_1", Sequence: 2})
	select {
	case got := <-ch:
		if got.Sequence != 2 {
			t.Fatalf("sequence = %d", got.Sequence)
		}
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for event")
	}
	unsubscribe()
	bus.Publish(Event{SessionID: "sess_1", Sequence: 3})
	select {
	case got, ok := <-ch:
		if ok {
			t.Fatalf("received after unsubscribe: %+v", got)
		}
	case <-time.After(time.Second):
		t.Fatal("channel did not close")
	}
}
