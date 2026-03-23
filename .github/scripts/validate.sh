#!/bin/bash
export LANG=C.UTF-8

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' 

echo "--------------------------------------------------------"
echo "Validación Lab 1: Inventario Farmacia (Python)"
echo "--------------------------------------------------------"

FAILED=0
FILE_PY=$(find . -name "*.py" | head -n 1)

if [ -z "$FILE_PY" ]; then
    echo -e "${RED}[ERROR] No se encontró ningún archivo .py.${NC}"
    exit 1
fi
echo -e "Archivo detectado: ${YELLOW}$FILE_PY${NC}\n"

# --- PASO 1: CLEAN CODE Y VARIABLES ---
echo -e "${YELLOW}PASO 1: Verificando Constantes y Variables...${NC}"
if grep -qE "STOCK_MINIMO_ALERTA\s*=\s*5" "$FILE_PY"; then echo -e "${GREEN}[OK] Constante STOCK_MINIMO_ALERTA correcta.${NC}"; else echo -e "${RED}[ERROR] Falta STOCK_MINIMO_ALERTA = 5.${NC}"; FAILED=1; fi

# --- PASO 2: FUNCIONES Y CASTING ---
echo -e "\n${YELLOW}PASO 2: Verificando Funciones y Casting Fuerte...${NC}"
if grep -qE "def\s+actualizar_stock" "$FILE_PY"; then echo -e "${GREEN}[OK] Función actualizar_stock encontrada.${NC}"; else echo -e "${RED}[ERROR] Falta la función actualizar_stock.${NC}"; FAILED=1; fi
if grep -qE "int\s*\(" "$FILE_PY"; then echo -e "${GREEN}[OK] Casting a entero detectado.${NC}"; else echo -e "${RED}[ERROR] No se usó int() para convertir el texto.${NC}"; FAILED=1; fi

# --- PASO 3: MUTABILIDAD ---
echo -e "\n${YELLOW}PASO 3: Verificando Copia Segura (Mutabilidad)...${NC}"
if grep -qE "respaldo_inventario\s*=\s*inventario_base\.copy\(\)" "$FILE_PY"; then
    echo -e "${GREEN}[OK] Uso correcto de .copy() para la lista.${NC}"
else
    echo -e "${RED}[ERROR] respaldo_inventario no usó .copy() de inventario_base.${NC}"
    FAILED=1
fi

# --- PASO 4: GARBAGE COLLECTOR ---
echo -e "\n${YELLOW}PASO 4: Verificando Garbage Collector...${NC}"
if grep -qE "respaldo_inventario\s*=\s*None" "$FILE_PY"; then echo -e "${GREEN}[OK] Memoria liberada correctamente.${NC}"; else echo -e "${RED}[ERROR] Falta asignar None al respaldo_inventario.${NC}"; FAILED=1; fi

# --- PASO 5: COMPILACIÓN Y SINTAXIS ---
echo -e "\n${YELLOW}PASO 5: Verificando sintaxis de Python...${NC}"
if python3 -m py_compile "$FILE_PY" 2>/dev/null; then
    echo -e "${GREEN}[OK] Compilación exitosa. Sin errores de sintaxis.${NC}"
else
    echo -e "${RED}[ERROR] El código tiene errores de sintaxis (indentación, faltan ':', etc.).${NC}"
    python3 -m py_compile "$FILE_PY" # Para mostrar el error exacto en consola
    FAILED=1
fi

# --- RESULTADO FINAL ---
if [ $FAILED -eq 0 ]; then echo -e "\n${GREEN}✔ LABORATORIO 1 APROBADO${NC}"; exit 0; else echo -e "\n${RED}✘ EL ALGORITMO NO CUMPLE LOS REQUISITOS O TIENE ERRORES DE SINTAXIS${NC}"; exit 1; fi