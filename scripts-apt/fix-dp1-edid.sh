#!/usr/bin/env bash
set -e

EDID_DIR="/lib/firmware/edid"
EDID_NAME="edid-dp1.bin"
TMP_TXT="/tmp/edid-dp1.txt"
TMP_BIN="/tmp/edid-dp1.bin"

echo "[+] Criando EDID mínimo para DP-1 (1440x900@75)..."

cat > "$TMP_TXT" << 'EOF'
00ffffffffffff004c2d900c00000000
011d010380291e78eaee95a3544c9926
0f5054bfef80714f818081c081009500
b30001010101023a801871382d40582c
4500fd1e1100001e000000fd00324b1e
5111000a202020202020000000fc0044
50312d31343430783930300a000000ff
00303030303030303030303030303000
EOF

echo "[+] Convertendo EDID para binário..."
xxd -r -p "$TMP_TXT" > "$TMP_BIN"

SIZE=$(stat -c%s "$TMP_BIN")
if [ "$SIZE" -ne 128 ]; then
  echo "[!] ERRO: EDID gerado não tem 128 bytes (tem $SIZE). Abortando."
  exit 1
fi

echo "[+] Instalando EDID em $EDID_DIR..."
sudo mkdir -p "$EDID_DIR"
sudo cp "$TMP_BIN" "$EDID_DIR/$EDID_NAME"

echo "[+] Aplicando parâmetros no kernel (kernelstub)..."
sudo kernelstub -a "drm.edid_firmware=DP-1:edid/$EDID_NAME video=DP-1:1440x900@75"

echo "[+] Limpando arquivos temporários..."
rm -f "$TMP_TXT" "$TMP_BIN"

echo
echo "[✓] Concluído com sucesso."
echo "    Reinicie o sistema para aplicar a resolução 1440x900@75 no DP-1."
echo
echo "    Para desfazer:"
echo "    sudo kernelstub -d 'drm.edid_firmware=DP-1:edid/$EDID_NAME video=DP-1:1440x900@75'"

