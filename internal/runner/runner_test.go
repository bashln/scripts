package runner

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"testing"
	"time"

	"bashln-scripts/internal/scripts"
)

func TestStartStreamEmitsDoneOnce(t *testing.T) {
	tmp := t.TempDir()
	scriptPath := filepath.Join(tmp, "ok.sh")
	content := "#!/bin/bash\necho hello\necho boom 1>&2\n"
	if err := os.WriteFile(scriptPath, []byte(content), 0o755); err != nil {
		t.Fatalf("failed writing script: %v", err)
	}

	logPath := filepath.Join(tmp, "install.log")
	stream := StartStream(context.Background(), scripts.Script{ID: "ok", Path: scriptPath}, logPath)

	var doneCount int
	var outputCount int
	for ev := range stream {
		switch ev.Type {
		case EventOutput:
			outputCount++
		case EventDone:
			doneCount++
			if ev.Err != nil {
				t.Fatalf("expected success, got error: %v", ev.Err)
			}
		}
	}

	if doneCount != 1 {
		t.Fatalf("expected 1 done event, got %d", doneCount)
	}

	if outputCount < 2 {
		t.Fatalf("expected at least 2 output events, got %d", outputCount)
	}
}

func TestStartStreamCancellation(t *testing.T) {
	tmp := t.TempDir()
	scriptPath := filepath.Join(tmp, "slow.sh")
	content := "#!/bin/bash\necho starting\nsleep 10\n"
	if err := os.WriteFile(scriptPath, []byte(content), 0o755); err != nil {
		t.Fatalf("failed writing script: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	stream := StartStream(ctx, scripts.Script{ID: "slow", Path: scriptPath}, filepath.Join(tmp, "install.log"))

	go func() {
		time.Sleep(150 * time.Millisecond)
		cancel()
	}()

	var doneErr error
	for ev := range stream {
		if ev.Type == EventDone {
			doneErr = ev.Err
		}
	}

	if doneErr == nil {
		t.Fatal("expected cancellation error, got nil")
	}

	if !errors.Is(doneErr, context.Canceled) {
		t.Fatalf("expected context cancellation error, got: %v", doneErr)
	}
}

func TestBuildCommandWithContextUsesProcessGroupCancellation(t *testing.T) {
	tmp := t.TempDir()
	scriptPath := filepath.Join(tmp, "noop.sh")
	content := "#!/bin/bash\nexit 0\n"
	if err := os.WriteFile(scriptPath, []byte(content), 0o755); err != nil {
		t.Fatalf("failed writing script: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cmd, err := BuildCommandWithContext(ctx, scripts.Script{ID: "noop", Path: scriptPath}, filepath.Join(tmp, "install.log"))
	if err != nil {
		t.Fatalf("expected command, got error: %v", err)
	}

	if cmd.SysProcAttr == nil || !cmd.SysProcAttr.Setpgid {
		t.Fatal("expected command process group isolation (Setpgid=true)")
	}

	if cmd.Cancel == nil {
		t.Fatal("expected custom cancellation function")
	}
}

func TestStartStreamCancellationDoesNotHangOnTermIgnoringScript(t *testing.T) {
	tmp := t.TempDir()
	scriptPath := filepath.Join(tmp, "ignore-term.sh")
	content := "#!/bin/bash\ntrap '' TERM\nwhile true; do sleep 1; done\n"
	if err := os.WriteFile(scriptPath, []byte(content), 0o755); err != nil {
		t.Fatalf("failed writing script: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	stream := StartStream(ctx, scripts.Script{ID: "ignore-term", Path: scriptPath}, filepath.Join(tmp, "install.log"))

	go func() {
		time.Sleep(150 * time.Millisecond)
		cancel()
	}()

	deadline := time.After(6 * time.Second)
	for {
		select {
		case ev, ok := <-stream:
			if !ok {
				t.Fatal("stream closed without done event")
			}
			if ev.Type != EventDone {
				continue
			}
			if ev.Err == nil {
				t.Fatal("expected cancellation error, got nil")
			}
			if !errors.Is(ev.Err, context.Canceled) {
				t.Fatalf("expected context cancellation error, got: %v", ev.Err)
			}
			return
		case <-deadline:
			t.Fatal("timeout waiting for canceled done event")
		}
	}
}

func TestBuildCommandFailsWithInvalidPath(t *testing.T) {
	tmp := t.TempDir()
	nonExistent := filepath.Join(tmp, "missing.sh")

	_, err := BuildCommand(scripts.Script{ID: "missing", Path: nonExistent}, filepath.Join(tmp, "install.log"))
	if err == nil {
		t.Fatal("expected error for invalid script path")
	}
}

func TestBuildCommandWithContextFailsWhenPathIsDirectory(t *testing.T) {
	tmp := t.TempDir()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	_, err := BuildCommandWithContext(ctx, scripts.Script{ID: "dir", Path: tmp}, filepath.Join(tmp, "install.log"))
	if err == nil {
		t.Fatal("expected build error when script path points to directory")
	}
}
