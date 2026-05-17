package ids

import (
	"crypto/rand"
	"time"

	"github.com/oklog/ulid/v2"
)

func New(prefix string) string {
	return prefix + "_" + ulid.MustNew(ulid.Timestamp(time.Now()), rand.Reader).String()
}
