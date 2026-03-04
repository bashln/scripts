package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	tea "github.com/charmbracelet/bubbletea"
	"golang.org/x/term"

	"bashln-scripts/internal/app"
	"bashln-scripts/internal/scripts"
)

func main() {
	rootFlag := flag.String("root", "", "Diretorio raiz do repositorio ou scripts-arch")
	noAltScreen := flag.Bool("no-alt-screen", false, "Desativa tela alternativa")
	flag.Parse()

	if !term.IsTerminal(int(os.Stdin.Fd())) || !term.IsTerminal(int(os.Stdout.Fd())) {
		fmt.Fprintln(os.Stderr, "erro: bashln-tui requer TTY interativo (stdin/stdout)")
		os.Exit(1)
	}

	root := filepath.Clean(resolveRoot(*rootFlag))
	archDir, err := resolveArchDir(root)
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro ao resolver scripts-arch: %v\n", err)
		os.Exit(1)
	}

	list, err := scripts.Discover(archDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro ao carregar scripts: %v\n", err)
		os.Exit(1)
	}

	model := app.NewModel(list, filepath.Join(archDir, "install.log"))
	options := []tea.ProgramOption{tea.WithInputTTY(), tea.WithOutput(os.Stdout)}
	if !*noAltScreen {
		options = append(options, tea.WithAltScreen())
	}
	p := tea.NewProgram(model, options...)

	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "erro na TUI: %v\n", err)
		os.Exit(1)
	}
}

func resolveRoot(rootFlag string) string {
	if rootFlag != "" {
		return rootFlag
	}

	if fromEnv := os.Getenv("BASHLN_ROOT"); fromEnv != "" {
		return fromEnv
	}

	cwd, err := os.Getwd()
	if err != nil {
		return "."
	}

	return cwd
}

func resolveArchDir(root string) (string, error) {
	candidates := []string{root, filepath.Join(root, "scripts-arch")}

	for _, dir := range candidates {
		installPath := filepath.Join(dir, "install.sh")
		assetsPath := filepath.Join(dir, "assets")

		if fileExists(installPath) && dirExists(assetsPath) {
			abs, err := filepath.Abs(dir)
			if err != nil {
				return "", err
			}
			return abs, nil
		}
	}

	return "", errors.New("nao foi encontrado scripts-arch valido (esperado install.sh e assets/)")
}

func fileExists(path string) bool {
	stat, err := os.Stat(path)
	return err == nil && !stat.IsDir()
}

func dirExists(path string) bool {
	stat, err := os.Stat(path)
	return err == nil && stat.IsDir()
}
