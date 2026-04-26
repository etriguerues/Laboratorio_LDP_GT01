#!/bin/bash
export LANG=C.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' 

echo "--------------------------------------------------------"
echo "Validación Lab 1: Generador de Tickets (Python)"
echo "--------------------------------------------------------"

FAILED=0
FILE_PY=$(find . -name "*.py" | head -n 1)
[ -z "$FILE_PY" ] && { echo -e "${RED}[ERROR] Sin archivo .py.${NC}"; exit 1; }
echo -e "Archivo detectado: ${YELLOW}$FILE_PY${NC}\n"

# --- PASO 1: VARIABLES GLOBALES Y SRP ---
echo -e "${YELLOW}PASO 1: Verificando variables globales y función SRP...${NC}"
if grep -qE "tickets\s*=\s*\[\]" "$FILE_PY" && grep -qE "def\s+formatear_ticket" "$FILE_PY" && grep -qE "return\s+" "$FILE_PY"; then echo -e "${GREEN}[OK] Variables globales y función de formateo detectadas.${NC}"; else echo -e "${RED}[ERROR] Falta 'tickets = []', o la función 'formatear_ticket' con su respectivo 'return'.${NC}"; FAILED=1; fi

# --- PASO 2: FUNCIONES ANIDADAS Y RECURSIVIDAD ---
echo -e "\n${YELLOW}PASO 2: Verificando Función Anidada, Caso Base y Recursividad...${NC}"
if grep -qE "def\s+generar_lote" "$FILE_PY" && grep -qE "def\s+agregar_recursivo" "$FILE_PY"; then echo -e "${GREEN}[OK] Funciones anidadas correctamente declaradas.${NC}"; else echo -e "${RED}[ERROR] Falta 'generar_lote' o su función interna 'agregar_recursivo'.${NC}"; FAILED=1; fi

if grep -qE "if\s+.*==\s*0:" "$FILE_PY" && grep -qE "return" "$FILE_PY" && grep -qE "agregar_recursivo\(.*\)" "$FILE_PY"; then echo -e "${GREEN}[OK] Caso base estricto y llamada recursiva implementados.${NC}"; else echo -e "${RED}[ERROR] Falla en la lógica recursiva: falta el 'if' para 0, el 'return' vacío o llamarse a sí misma.${NC}"; FAILED=1; fi

# --- PASO 3: TRAMPA DE REASIGNACIÓN (VALOR VS REFERENCIA) ---
echo -e "\n${YELLOW}PASO 3: Verificando Paso por Referencia y Trampa de Reasignación...${NC}"
if grep -qE "\.append\(" "$FILE_PY"; then echo -e "${GREEN}[OK] Lista modificada por referencia (.append).${NC}"; else echo -e "${RED}[ERROR] No se usó .append() para modificar la lista de tickets.${NC}"; FAILED=1; fi
if grep -qE "def\s+apagar_servidor" "$FILE_PY" && grep -qE "=\s*[\"']Offline[\"']" "$FILE_PY"; then echo -e "${GREEN}[OK] Función de trampa de alcance (Scope) verificada.${NC}"; else echo -e "${RED}[ERROR] Falta 'apagar_servidor' o la reasignación local a 'Offline'.${NC}"; FAILED=1; fi

# --- PASO 4: COMPILACIÓN ---
echo -e "\n${YELLOW}PASO 4: Verificando sintaxis...${NC}"
if python3 -m py_compile "$FILE_PY" 2>/dev/null; then echo -e "${GREEN}[OK] Sintaxis correcta.${NC}"; else echo -e "${RED}[ERROR] Error de sintaxis en el código.${NC}"; FAILED=1; fi

[ $FAILED -eq 0 ] && { echo -e "\n${GREEN}✔ LABORATORIO 1 APROBADO${NC}"; exit 0; } || { echo -e "\n${RED}✘ LAB FALLIDO${NC}"; exit 1; }