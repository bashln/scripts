package scripts

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

var (
	stepEnabledRe     = regexp.MustCompile(`^\s*["']?([a-zA-Z0-9._-]+\.sh)["']?\s*(?:#.*)?$`)
	stepDisabledRe    = regexp.MustCompile(`^\s*#\s*["']?([a-zA-Z0-9._-]+\.sh)["']?\s*(?:#.*)?$`)
	requiresRootRe    = regexp.MustCompile(`(?m)^REQUIRES_ROOT=1\s*$`)
	sudoUsageRe       = regexp.MustCompile(`(?m)\bsudo\b`)
	ensureRootCallRe  = regexp.MustCompile(`(?m)\b(ensure_package|ensure_aur_package|ensure_copr_package|ensure_group|ensure_rpmfusion)\b`)
	interactiveHint   = regexp.MustCompile(`(?m)(\bread\b|--interactive|gum\s+(input|confirm|choose|filter|file)|\bfzf\b|\bwhiptail\b|\bdialog\b|\bselect\s+)`)
	metaInteractiveRe = regexp.MustCompile(`(?m)^\s*#\s*TUI_INTERACTIVE\s*:\s*true\s*$`)
	metaRootRe        = regexp.MustCompile(`(?m)^\s*#\s*TUI_REQUIRES_ROOT\s*:\s*true\s*$`)
)

func Discover(archDir string) ([]Script, error) {
	installPath := filepath.Join(archDir, "install.sh")
	orderMap, enabledMap, err := parseSteps(installPath)
	if err != nil {
		return nil, err
	}

	overrides, err := loadOverrides(filepath.Join(archDir, "tui-overrides.json"))
	if err != nil {
		return nil, err
	}

	assetsDir := filepath.Join(archDir, "assets")
	entries, err := os.ReadDir(assetsDir)
	if err != nil {
		return nil, fmt.Errorf("erro lendo assets: %w", err)
	}

	items := make([]Script, 0, len(entries))
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".sh" {
			continue
		}

		fullPath := filepath.Join(assetsDir, entry.Name())
		body, readErr := os.ReadFile(fullPath)
		if readErr != nil {
			return nil, fmt.Errorf("erro lendo script %s: %w", entry.Name(), readErr)
		}

		order, found := orderMap[entry.Name()]
		if !found {
			order = 10000
		}

		requiresRoot := detectRequiresRoot(entry.Name(), body, overrides)
		interactive := interactiveHint.Match(body) || metaInteractiveRe.Match(body)

		script := Script{
			ID:           strings.TrimSuffix(entry.Name(), ".sh"),
			Name:         defaultName(entry.Name()),
			Path:         fullPath,
			Enabled:      enabledMap[entry.Name()],
			RequiresRoot: requiresRoot,
			Interactive:  interactive,
			Status:       StatusIdle,
			Order:        order,
		}
		applyOverrides(&script, overrides)
		items = append(items, script)
	}

	sort.Slice(items, func(i, j int) bool {
		if items[i].Order != items[j].Order {
			return items[i].Order < items[j].Order
		}
		return filepath.Base(items[i].Path) < filepath.Base(items[j].Path)
	})

	return items, nil
}

func detectRequiresRoot(scriptName string, body []byte, overrides Overrides) bool {
	if overrides.RequiresRoot[scriptName] {
		return true
	}

	if metaRootRe.Match(body) {
		return true
	}

	bodyWithoutComments := stripCommentOnlyLines(body)

	if sudoUsageRe.Match(bodyWithoutComments) {
		return true
	}

	if ensureRootCallRe.Match(bodyWithoutComments) {
		return true
	}

	return requiresRootRe.Match(body)
}

func stripCommentOnlyLines(body []byte) []byte {
	lines := strings.Split(string(body), "\n")
	filtered := make([]string, 0, len(lines))
	for _, line := range lines {
		if strings.HasPrefix(strings.TrimSpace(line), "#") {
			continue
		}
		filtered = append(filtered, line)
	}

	return []byte(strings.Join(filtered, "\n"))
}

func parseSteps(installPath string) (map[string]int, map[string]bool, error) {
	file, err := os.Open(installPath)
	if err != nil {
		return nil, nil, fmt.Errorf("erro abrindo install.sh: %w", err)
	}
	defer file.Close()

	order := map[string]int{}
	enabled := map[string]bool{}

	index := 0
	insideSteps := false
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		if strings.HasPrefix(line, "STEPS=(") {
			insideSteps = true
			continue
		}

		if insideSteps && line == ")" {
			break
		}

		if !insideSteps || line == "" {
			continue
		}

		if disabled := stepDisabledRe.FindStringSubmatch(line); len(disabled) == 2 {
			name := disabled[1]
			if _, exists := order[name]; !exists {
				order[name] = index
				enabled[name] = false
				index++
			}
			continue
		}

		match := stepEnabledRe.FindStringSubmatch(line)
		if len(match) != 2 {
			continue
		}

		name := match[1]
		if _, exists := order[name]; !exists {
			order[name] = index
			enabled[name] = true
			index++
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, nil, fmt.Errorf("erro ao ler install.sh: %w", err)
	}

	return order, enabled, nil
}
