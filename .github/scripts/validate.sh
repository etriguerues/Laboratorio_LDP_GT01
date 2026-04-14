#!/bin/bash
export LANG=C.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' 

echo "--------------------------------------------------------"
echo "Validación Lab: Procesador de Pedidos (Python)"
echo "--------------------------------------------------------"

FAILED=0
FILE_PY=$(find . -name "*.py" | head -n 1)
[ -z "$FILE_PY" ] && { echo -e "${RED}[ERROR] Sin archivo .py.${NC}"; exit 1; }
echo -e "Archivo detectado: ${YELLOW}$FILE_PY${NC}\n"

# --- PASO 1: FUNCION Y GUARDA ---
echo -e "${YELLOW}PASO 1: Verificando Función y Cláusula de Guarda...${NC}"
if grep -qE "def\s+procesar_plato" "$FILE_PY" && grep -qE "if\s+.*==\s*[\"']Nada[\"']:" "$FILE_PY" && grep -qE "return\s+0" "$FILE_PY"; then echo -e "${GREEN}[OK] Función y cláusula de guarda correctas.${NC}"; else echo -e "${RED}[ERROR] Falta procesar_plato, el if de guarda ('Nada') o el return 0.${NC}"; FAILED=1; fi

# --- PASO 2: PATTERN MATCHING ---
echo -e "\n${YELLOW}PASO 2: Verificando Pattern Matching (match-case)...${NC}"
if grep -qE "match\s+" "$FILE_PY" && grep -qE "case\s+[\"']Frio[\"']:" "$FILE_PY" && grep -qE "case\s+_:" "$FILE_PY"; then echo -e "${GREEN}[OK] Estructura match-case detectada correctamente.${NC}"; else echo -e "${RED}[ERROR] No se usó match, case 'Frio' o el comodín 'case _:'.${NC}"; FAILED=1; fi

# --- PASO 3: CICLOS FOR Y WHILE ---
echo -e "\n${YELLOW}PASO 3: Verificando Ciclos (for y while)...${NC}"
if grep -qE "for\s+.*\s+in\s+pedidos:" "$FILE_PY" && grep -qE "while\s+tiempo_total\s*>\s*0:" "$FILE_PY"; then echo -e "${GREEN}[OK] Ciclos for y while implementados.${NC}"; else echo -e "${RED}[ERROR] Error en la declaración del 'for' o la condición del 'while'.${NC}"; FAILED=1; fi

# --- PASO 4: CORTOCIRCUITO Y TERNARIO ---
echo -e "\n${YELLOW}PASO 4: Verificando Cortocircuito y Operador Ternario...${NC}"
if grep -qE "if\s+.*and\s+cocina_abierta:" "$FILE_PY"; then echo -e "${GREEN}[OK] Cortocircuito con 'and' detectado.${NC}"; else echo -e "${RED}[ERROR] Falta el 'if' usando el operador lógico 'and'.${NC}"; FAILED=1; fi
if grep -qE "=\s*[\"'].*[\"']\s+if\s+.*\s+else\s+[\"'].*[\"']" "$FILE_PY"; then echo -e "${GREEN}[OK] Operador ternario detectado en una sola línea.${NC}"; else echo -e "${RED}[ERROR] No se detectó la asignación de variable mediante operador ternario.${NC}"; FAILED=1; fi

# --- PASO 5: COMPILACIÓN Y SINTAXIS ---
echo -e "\n${YELLOW}PASO 5: Verificando sintaxis de Python 3.10+...${NC}"
if python3 -m py_compile "$FILE_PY" 2>/dev/null; then 
    echo -e "${GREEN}[OK] Sintaxis correcta.${NC}"
else 
    echo -e "${RED}[ERROR] Error de sintaxis (¿Quizás usan una versión anterior a Python 3.10?).${NC}"
    python3 -m py_compile "$FILE_PY"
    FAILED=1
fi

[ $FAILED -eq 0 ] && { echo -e "\n${GREEN}✔ LABORATORIO 1 APROBADO${NC}"; exit 0; } || { echo -e "\n${RED}✘ LAB FALLIDO${NC}"; exit 1; }