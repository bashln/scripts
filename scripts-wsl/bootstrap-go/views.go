package main

import (
	"fmt"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("cyan")).
			Padding(1, 0)

	selectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("green")).
			Bold(true)

	normalStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("white"))

	descriptionStyle = lipgloss.NewStyle().
				Foreground(lipgloss.Color("gray")).
				Faint(true)

	headerStyle = lipgloss.NewStyle().
			Background(lipgloss.Color("cyan")).
			Foreground(lipgloss.Color("black")).
			Bold(true).
			Padding(0, 1)

	categoryStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("yellow")).
			Bold(true).
			MarginTop(1)

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("gray")).
			Faint(true)

	boxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("cyan")).
			Padding(1, 2)

	errorStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("red")).
			Bold(true)

	successStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("green")).
			Bold(true)

	logStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("white"))

	logErrorStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("red"))

	logSuccessStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("green"))
)

// tickMsg is sent every 100ms to check for new logs
type tickMsg time.Time

// Update handles messages and updates the model
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		return m, nil

	case tea.KeyMsg:
		switch msg.String() {
		case "q", "esc":
			if m.state == StateMenu {
				return m, tea.Quit
			} else if m.state == StateInstalling {
				m.state = StateMenu
				m.installing = ""
				m.logs = []string{}
				m.logChan = make(chan string, 100)
				return m, nil
			}

		case "up", "k":
			if m.state == StateMenu {
				if m.selected > 0 {
					m.selected--
				}
			}

		case "down", "j":
			if m.state == StateMenu {
				if m.selected < len(m.menuItems)-1 {
					m.selected++
				}
			}

		case "enter":
			if m.state == StateMenu {
				item := m.menuItems[m.selected]

				if item.ID == "check-distros" {
					m.state = StateChecking
					return m, checkDistros()
				}

				m.state = StateInstalling
				m.installing = item.Title
				m.logs = []string{fmt.Sprintf("Iniciando: %s", item.Title), "", "Aguarde..."}

				// Start installation based on type
				if item.Script == "all" {
					return m, tea.Batch(
						runAllInstall(m.logChan),
						tickCmd(),
					)
				} else {
					return m, tea.Batch(
						runScriptWithLogs(item, m.logChan),
						tickCmd(),
					)
				}
			}

		case "backspace":
			if m.state == StateDone || m.state == StateError {
				m.state = StateMenu
				m.err = nil
				m.logs = []string{}
				m.logChan = make(chan string, 100)
				return m, nil
			}
		}

	case wslCheckMsg:
		m.wslInstalled = msg.installed
		return m, nil

	case distroListMsg:
		if msg.err != nil {
			m.state = StateError
			m.err = msg.err
		} else {
			m.distros = msg.distros
			m.state = StateDone
		}
		return m, nil

	case installCompleteMsg:
		if msg.err != nil {
			m.state = StateError
			m.err = msg.err
		} else {
			m.state = StateDone
		}
		return m, nil

	case tickMsg:
	loop:
		for {
			select {
			case log := <-m.logChan:
				m.logs = append(m.logs, log)
				if len(m.logs) > 50 {
					m.logs = m.logs[len(m.logs)-50:]
				}
			default:
				break loop
			}
		}

		if m.state == StateInstalling {
			return m, tickCmd()
		}
		return m, nil
	}

	return m, nil
}

// tickCmd returns a command that ticks every 100ms
func tickCmd() tea.Cmd {
	return tea.Tick(100*time.Millisecond, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

// View renders the UI
func (m Model) View() string {
	switch m.state {
	case StateMenu:
		return m.renderMenu()
	case StateInstalling:
		return m.renderInstalling()
	case StateDone:
		return m.renderDone()
	case StateError:
		return m.renderError()
	case StateChecking:
		return m.renderChecking()
	default:
		return ""
	}
}

func (m Model) renderMenu() string {
	var b strings.Builder

	// Title
	b.WriteString(titleStyle.Render("🐧 WSL Bootstrap v2.0"))
	b.WriteString("\n")

	// WSL Status
	if m.wslInstalled {
		b.WriteString(successStyle.Render("  ✓ Rodando no WSL"))
	} else {
		b.WriteString(errorStyle.Render("  ✗ Não está no WSL"))
	}
	b.WriteString("\n\n")

	// Menu items grouped by category
	categoryNames := []string{"INSTALAÇÃO", "SISTEMA", "UTILITÁRIOS"}

	for cat, catName := range categoryNames {
		category := Category(cat)

		// Category header
		b.WriteString(categoryStyle.Render(catName))
		b.WriteString("\n")

		// Items in category
		for i, item := range m.menuItems {
			if item.Category == category {
				cursor := "  "
				style := normalStyle
				if m.selected == i {
					cursor = "▸ "
					style = selectedStyle
				}

				itemText := fmt.Sprintf("%s%s", cursor, item.Title)
				b.WriteString(style.Render(itemText))

				if m.selected == i {
					b.WriteString("\n")
					b.WriteString(descriptionStyle.Render(fmt.Sprintf("     %s", item.Description)))
				}
				b.WriteString("\n")
			}
		}
		b.WriteString("\n")
	}

	// Help
	b.WriteString(helpStyle.Render("  ↑/↓ ou j/k: navegar • Enter: selecionar • q: sair"))

	return b.String()
}

func (m Model) renderInstalling() string {
	var b strings.Builder

	b.WriteString(titleStyle.Render("⏳ Instalando..."))
	b.WriteString("\n\n")

	b.WriteString(normalStyle.Render(fmt.Sprintf("  Executando: %s", m.installing)))
	b.WriteString("\n\n")

	// Progress bar
	progress := strings.Repeat("█", m.progress/5) + strings.Repeat("░", 20-m.progress/5)
	b.WriteString(fmt.Sprintf("  [%s] %d%%", progress, m.progress))
	b.WriteString("\n\n")

	// Logs box
	b.WriteString("  Logs:\n")
	b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")

	// Show last logs (fit in screen)
	maxLogs := min(len(m.logs), 15)
	startIdx := len(m.logs) - maxLogs
	if startIdx < 0 {
		startIdx = 0
	}

	for i := startIdx; i < len(m.logs); i++ {
		log := m.logs[i]
		// Truncate long lines
		maxWidth := min(m.width-6, 74)
		if len(log) > maxWidth {
			log = log[:maxWidth-3] + "..."
		}

		// Apply style based on content
		style := logStyle
		if strings.HasPrefix(log, "[ERRO]") || strings.HasPrefix(log, "[FALHA]") || strings.HasPrefix(log, "[ERROR]") {
			style = logErrorStyle
		} else if strings.HasPrefix(log, "[OK]") || strings.HasPrefix(log, "[SUCESSO]") {
			style = logSuccessStyle
		}

		b.WriteString("  " + style.Render(log) + "\n")
	}

	b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")

	b.WriteString("\n")
	b.WriteString(helpStyle.Render("  Pressione ESC para voltar ao menu"))

	return b.String()
}

func (m Model) renderDone() string {
	var b strings.Builder

	b.WriteString(titleStyle.Render("✅ Concluído!"))
	b.WriteString("\n\n")

	// Show final logs if any
	if len(m.logs) > 0 {
		b.WriteString("  Últimos logs:\n")
		b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")

		maxLogs := min(len(m.logs), 10)
		startIdx := len(m.logs) - maxLogs
		if startIdx < 0 {
			startIdx = 0
		}

		for i := startIdx; i < len(m.logs); i++ {
			log := m.logs[i]
			maxWidth := min(m.width-6, 74)
			if len(log) > maxWidth {
				log = log[:maxWidth-3] + "..."
			}

			style := logStyle
			if strings.HasPrefix(log, "[ERRO]") || strings.HasPrefix(log, "[FALHA]") {
				style = logErrorStyle
			} else if strings.HasPrefix(log, "[OK]") || strings.HasPrefix(log, "[SUCESSO]") {
				style = logSuccessStyle
			}

			b.WriteString("  " + style.Render(log) + "\n")
		}
		b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")
		b.WriteString("\n")
	}

	if m.err != nil {
		b.WriteString(errorStyle.Render("  ❌ Erro: " + m.err.Error()))
	} else {
		b.WriteString(successStyle.Render("  ✓ Operação concluída com sucesso!"))
	}

	b.WriteString("\n\n")
	b.WriteString(helpStyle.Render("  Pressione BACKSPACE para voltar ao menu"))

	return b.String()
}

func (m Model) renderError() string {
	var b strings.Builder

	b.WriteString(titleStyle.Render("❌ Erro"))
	b.WriteString("\n\n")

	b.WriteString(errorStyle.Render(fmt.Sprintf("  %v", m.err)))
	b.WriteString("\n\n")

	if len(m.logs) > 0 {
		b.WriteString("  Logs antes do erro:\n")
		b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")

		maxLogs := min(len(m.logs), 10)
		for i := len(m.logs) - maxLogs; i < len(m.logs); i++ {
			if i >= 0 {
				b.WriteString("  " + m.logs[i] + "\n")
			}
		}
		b.WriteString("  " + strings.Repeat("─", min(m.width-4, 76)) + "\n")
		b.WriteString("\n")
	}

	b.WriteString(helpStyle.Render("  Pressione BACKSPACE para voltar ao menu"))

	return b.String()
}

func (m Model) renderChecking() string {
	var b strings.Builder

	b.WriteString(titleStyle.Render("🔍 Verificando..."))
	b.WriteString("\n\n")

	b.WriteString(normalStyle.Render("  Buscando distribuições WSL..."))
	b.WriteString("\n")
	b.WriteString(normalStyle.Render("  Aguarde..."))

	return b.String()
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
