#!/bin/bash
export LANG=C.UTF-8
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' 

echo "--------------------------------------------------------"
echo "Validación Lab: Motor de Videojuegos"
echo "--------------------------------------------------------"

FAILED=0
FILE_PY=$(find . -name "*.py" | head -n 1)
[ -z "$FILE_PY" ] && { echo -e "${RED}[ERROR] Sin archivo .py.${NC}"; exit 1; }

echo -e "${YELLOW}PASO 1: Verificando Importaciones y Arreglo...${NC}"
if grep -qE "import array" "$FILE_PY" && grep -qE "json" "$FILE_PY" && grep -qE "deque" "$FILE_PY" && grep -qE "array\.array\(\s*['\"]i['\"]" "$FILE_PY"; then echo -e "${GREEN}[OK] Importaciones y array tipado correctos.${NC}"; else echo -e "${RED}[ERROR] Faltan imports o el arreglo 'i'.${NC}"; FAILED=1; fi

echo -e "\n${YELLOW}PASO 2: Verificando Lista, Matriz y Cola...${NC}"
if grep -qE "\.append\(\s*['\"]Espada['\"]\s*\)" "$FILE_PY" && grep -qE "\[1\]\[0\]\s*=\s*['\"]Puerta['\"]" "$FILE_PY" && grep -qE "\.popleft\(\)" "$FILE_PY"; then echo -e "${GREEN}[OK] Modificaciones de lista, matriz y deque (.popleft) verificadas.${NC}"; else echo -e "${RED}[ERROR] Error en .append, en las coordenadas [1][0] o falta .popleft().${NC}"; FAILED=1; fi

echo -e "\n${YELLOW}PASO 3: Verificando Serialización JSON...${NC}"
if grep -qE "json\.dumps\(" "$FILE_PY"; then echo -e "${GREEN}[OK] Serialización JSON aplicada.${NC}"; else echo -e "${RED}[ERROR] No se usó json.dumps().${NC}"; FAILED=1; fi

if python3 -m py_compile "$FILE_PY" 2>/dev/null; then echo -e "\n${GREEN}[OK] Sintaxis correcta.${NC}"; else echo -e "\n${RED}[ERROR] Error de sintaxis en el código.${NC}"; FAILED=1; fi

[ $FAILED -eq 0 ] && { echo -e "\n${GREEN}✔ LABORATORIO 1 APROBADO${NC}"; exit 0; } || { echo -e "\n${RED}✘ LAB FALLIDO${NC}"; exit 1; }
