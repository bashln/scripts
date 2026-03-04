package app

import (
	"context"
	"testing"

	tea "github.com/charmbracelet/bubbletea"

	"bashln-scripts/internal/runner"
	"bashln-scripts/internal/scripts"
)

func TestToggleAllBehavior(t *testing.T) {
	list := []scripts.Script{
		{ID: "a", Enabled: true},
		{ID: "b", Enabled: false},
	}

	m := NewModel(list, "install.log")
	updated, _ := m.handleListKeys(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'a'}})
	m2 := updated.(Model)

	if !m2.scripts[0].Enabled || !m2.scripts[1].Enabled {
		t.Fatal("expected toggle-all to enable every script when at least one is disabled")
	}

	updated, _ = m2.handleListKeys(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'a'}})
	m3 := updated.(Model)

	if m3.scripts[0].Enabled || m3.scripts[1].Enabled {
		t.Fatal("expected toggle-all to disable every script when all are enabled")
	}
}

func TestInteractiveCancelIsMarkedCanceled(t *testing.T) {
	list := []scripts.Script{{ID: "interactive", Enabled: true, Interactive: true, Status: scripts.StatusRunning}}
	m := NewModel(list, "install.log")
	m.mode = modeRunning
	m.current = 0
	m.cancelRequested = true

	updatedModel, _ := m.Update(interactiveDoneMsg{idx: 0, err: context.Canceled})
	updated := updatedModel.(Model)

	if updated.scripts[0].Status != scripts.StatusCanceled {
		t.Fatalf("expected status canceled, got %s", updated.scripts[0].Status)
	}

	if updated.canceledCount != 1 {
		t.Fatalf("expected canceled count 1, got %d", updated.canceledCount)
	}
}

func TestStartRunBlockedWhenAlreadyRunning(t *testing.T) {
	list := []scripts.Script{{ID: "a", Enabled: true, Status: scripts.StatusRunning}}
	m := NewModel(list, "install.log")
	m.mode = modeRunning
	m.queue = []int{0}
	m.queuePos = 1

	updatedModel, cmd := m.startRun()
	updated := updatedModel.(Model)

	if cmd != nil {
		t.Fatal("expected nil command when run is already active")
	}

	if updated.mode != modeRunning {
		t.Fatalf("expected mode running, got %s", updated.mode)
	}

	if updated.lastMessage != "Execucao ja em andamento." {
		t.Fatalf("unexpected message: %q", updated.lastMessage)
	}
}

func TestHandleRunningKeysBlocksRerunShortcut(t *testing.T) {
	m := NewModel([]scripts.Script{{ID: "a", Enabled: true}}, "install.log")
	m.mode = modeRunning

	updatedModel, cmd := m.handleRunningKeys(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'r'}})
	updated := updatedModel.(Model)

	if cmd != nil {
		t.Fatal("expected nil command for rerun key during execution")
	}

	if updated.lastMessage != "Execucao ja em andamento." {
		t.Fatalf("unexpected message: %q", updated.lastMessage)
	}
}

func TestMarkRemainingSkippedKeepsCurrentAndSkipsPending(t *testing.T) {
	list := []scripts.Script{
		{ID: "current", Enabled: true, Status: scripts.StatusRunning},
		{ID: "next", Enabled: true, Status: scripts.StatusQueued, LastError: "old"},
		{ID: "later", Enabled: true, Status: scripts.StatusQueued, LastError: "old"},
	}

	m := NewModel(list, "install.log")
	m.queue = []int{0, 1, 2}
	m.queuePos = 1
	m.current = 0

	m.markRemainingSkipped()

	if m.scripts[0].Status != scripts.StatusRunning {
		t.Fatalf("expected current script to remain running, got %s", m.scripts[0].Status)
	}

	if m.scripts[1].Status != scripts.StatusSkipped || m.scripts[2].Status != scripts.StatusSkipped {
		t.Fatalf("expected pending scripts to be skipped, got %s and %s", m.scripts[1].Status, m.scripts[2].Status)
	}

	if m.scripts[1].LastError != "" || m.scripts[2].LastError != "" {
		t.Fatal("expected skipped scripts to have empty last error")
	}
}

func TestRunDoneMsgResetsFinalState(t *testing.T) {
	m := NewModel([]scripts.Script{{ID: "a", Enabled: true}}, "install.log")
	m.mode = modeRunning
	m.current = 0
	m.cancelRequested = true
	m.runCancel = func() {}
	m.successCount = 1
	m.failureCount = 2
	m.canceledCount = 3

	updatedModel, cmd := m.Update(runDoneMsg{})
	updated := updatedModel.(Model)

	if cmd != nil {
		t.Fatal("expected nil command after runDoneMsg")
	}

	if updated.mode != modeMainMenu {
		t.Fatalf("expected mode main menu, got %s", updated.mode)
	}
	if updated.current != -1 {
		t.Fatalf("expected current index -1, got %d", updated.current)
	}
	if updated.runCancel != nil {
		t.Fatal("expected runCancel nil")
	}
	if updated.cancelRequested {
		t.Fatal("expected cancelRequested false")
	}
	if updated.lastMessage != "Execucao finalizada: 1 sucesso(s), 2 falha(s), 3 cancelado(s)." {
		t.Fatalf("unexpected message: %q", updated.lastMessage)
	}
}

func TestStreamEventDoneCanceledMarksScriptAndSchedulesRunDone(t *testing.T) {
	list := []scripts.Script{{ID: "a", Enabled: true, Status: scripts.StatusRunning}}
	m := NewModel(list, "install.log")
	m.mode = modeRunning
	m.current = 0
	m.queue = []int{0}
	m.queuePos = 1

	updatedModel, cmd := m.Update(streamEventMsg{
		event: runner.Event{Type: runner.EventDone, Script: list[0], Err: context.Canceled},
		ok:    true,
	})
	updated := updatedModel.(Model)

	if updated.scripts[0].Status != scripts.StatusCanceled {
		t.Fatalf("expected canceled status, got %s", updated.scripts[0].Status)
	}
	if updated.canceledCount != 1 {
		t.Fatalf("expected canceled count 1, got %d", updated.canceledCount)
	}
	if cmd == nil {
		t.Fatal("expected follow-up command to emit runDoneMsg")
	}
}

func TestHandleRunningKeysCancelMarksPendingAsSkipped(t *testing.T) {
	list := []scripts.Script{
		{ID: "current", Enabled: true, Status: scripts.StatusRunning},
		{ID: "next", Enabled: true, Status: scripts.StatusQueued},
	}
	m := NewModel(list, "install.log")
	m.mode = modeRunning
	m.current = 0
	m.queue = []int{0, 1}
	m.queuePos = 1

	updatedModel, cmd := m.handleRunningKeys(tea.KeyMsg{Type: tea.KeyEsc})
	updated := updatedModel.(Model)

	if cmd != nil {
		t.Fatal("expected nil command when requesting cancel")
	}
	if !updated.cancelRequested {
		t.Fatal("expected cancelRequested true")
	}
	if updated.scripts[1].Status != scripts.StatusSkipped {
		t.Fatalf("expected pending script skipped, got %s", updated.scripts[1].Status)
	}
	if updated.lastMessage != "Script interativo em foreground; finalize-o para continuar." {
		t.Fatalf("unexpected message: %q", updated.lastMessage)
	}
}

func TestNewModelStartsAtMainMenu(t *testing.T) {
	m := NewModel([]scripts.Script{{ID: "a", Enabled: true}}, "/tmp/install.log")

	if m.mode != modeMainMenu {
		t.Fatalf("expected mode main menu, got %s", m.mode)
	}
}

func TestHandleMainMenuEnterRoutesToExpectedScreen(t *testing.T) {
	m := NewModel([]scripts.Script{{ID: "a", Enabled: true}}, "install.log")

	updatedModel, _ := m.handleMainMenuKeys(tea.KeyMsg{Type: tea.KeyEnter})
	updated := updatedModel.(Model)
	if updated.mode != modeList {
		t.Fatalf("expected mode list, got %s", updated.mode)
	}

	updated.menuCursor = mainMenuSettings
	updatedModel, _ = updated.handleMainMenuKeys(tea.KeyMsg{Type: tea.KeyEnter})
	updated = updatedModel.(Model)
	if updated.mode != modeSettings {
		t.Fatalf("expected mode settings, got %s", updated.mode)
	}
}

func TestEscBackFromListAndSettings(t *testing.T) {
	m := NewModel([]scripts.Script{{ID: "a", Enabled: true}}, "install.log")
	m.mode = modeList

	updatedModel, cmd := m.handleListKeys(tea.KeyMsg{Type: tea.KeyEsc})
	updated := updatedModel.(Model)
	if cmd != nil {
		t.Fatal("expected nil command when going back from list")
	}
	if updated.mode != modeMainMenu {
		t.Fatalf("expected mode main menu, got %s", updated.mode)
	}

	updated.mode = modeSettings
	updatedModel, cmd = updated.handleSettingsKeys(tea.KeyMsg{Type: tea.KeyEsc})
	updated = updatedModel.(Model)
	if cmd != nil {
		t.Fatal("expected nil command when going back from settings")
	}
	if updated.mode != modeMainMenu {
		t.Fatalf("expected mode main menu, got %s", updated.mode)
	}
}
