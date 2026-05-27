#!/bin/bash
export LANG=C.UTF-8
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0;0m' 
FAILED=0

FILE_PY=$(find . -name "*.py" | head -n 1)
[ -z "$FILE_PY" ] && { echo -e "${RED}[ERROR] Sin archivo .py.${NC}"; exit 1; }

# Validar Búsqueda Lineal: Nombre + range(len()) + return -1
if grep -qE "def busqueda_lineal_id" "$FILE_PY" && grep -qE "range\s*\(\s*len\s*\(" "$FILE_PY" && grep -qE "return\s+-1" "$FILE_PY"; then echo -e "${GREEN}✔ Búsqueda Lineal OK${NC}"; else echo -e "${RED}✘ Falla en busqueda_lineal_id (Verifique el uso de range(len()) y return -1)${NC}"; FAILED=1; fi

# Validar Búsqueda Binaria: Nombre + while + // 2
if grep -qE "def busqueda_binaria_id" "$FILE_PY" && grep -qE "while.*:" "$FILE_PY" && grep -qE "//\s*2" "$FILE_PY"; then echo -e "${GREEN}✔ Búsqueda Binaria OK${NC}"; else echo -e "${RED}✘ Falla en busqueda_binaria_id (Verifique el uso del ciclo while y división entera // 2)${NC}"; FAILED=1; fi

# Validar Bubble Sort: Nombre + for anidado + swap ([j+1])
if grep -qE "def ordenar_precios_burbuja" "$FILE_PY" && grep -qE "for.*in range" "$FILE_PY" && grep -qE "\[\s*j\s*\+\s*1\s*\]" "$FILE_PY"; then echo -e "${GREEN}✔ Bubble Sort OK${NC}"; else echo -e "${RED}✘ Falla en ordenar_precios_burbuja (Falta anidación correcta o intercambio [j+1])${NC}"; FAILED=1; fi

# Validar Quick Sort: Nombre + pivote + listas por comprensión
if grep -qE "def ordenar_precios_quick" "$FILE_PY" && grep -qE "pivote" "$FILE_PY" && grep -qE "\[.*for.*in.*\]" "$FILE_PY"; then echo -e "${GREEN}✔ Quick Sort OK${NC}"; else echo -e "${RED}✘ Falla en ordenar_precios_quick (Falta pivote o las listas por comprensión)${NC}"; FAILED=1; fi

python3 -m py_compile "$FILE_PY" 2>/dev/null || { echo -e "${RED}✘ Error de sintaxis${NC}"; FAILED=1; }
[ $FAILED -eq 0 ] && exit 0 || exit 1
