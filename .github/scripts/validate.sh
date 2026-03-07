#!/bin/bash
export LANG=C.UTF-8

# Colores para la salida en consola
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0;0m' # Sin color

echo "--------------------------------------------------------"
echo "Iniciando validación: Algoritmo Calculadora IMC (PSeInt)"
echo "--------------------------------------------------------"

# Variable de control de errores
FAILED=0

# Buscar el archivo .psc (asumimos que hay uno en la carpeta raíz o subcarpetas)
FILE_PSC=$(find . -name "*.psc" | head -n 1)

if [ -z "$FILE_PSC" ]; then
    echo -e "${RED}[ERROR] No se encontró ningún archivo .psc (PSeInt).${NC}"
    exit 1
fi

echo -e "Archivo detectado: ${YELLOW}$FILE_PSC${NC}"

# --- PASO 1: VERIFICAR FUNCIÓN OBLIGATORIA ---
echo -e "\n${YELLOW}PASO 1: Verificando Función CalcularIMC...${NC}"

# Validar definición de la función y nombre exacto
if grep -qi "Funcion.*CalcularIMC" "$FILE_PSC"; then
    echo -e "${GREEN}[OK] Función 'CalcularIMC' definida.${GREEN}"
else
    echo -e "${RED}[ERROR] No se encontró la función 'CalcularIMC'.${NC}"
    FAILED=1
fi

# Validar fórmula matemática peso / (altura * altura)
if grep -qE "peso\s*/\s*\(\s*altura\s*\*\s*altura\s*\)" "$FILE_PSC"; then
    echo -e "${GREEN}[OK] Fórmula de IMC correcta.${NC}"
else
    echo -e "${RED}[ERROR] No se encontró la fórmula correcta: peso / (altura * altura).${NC}"
    FAILED=1
fi

# --- PASO 2: VERIFICAR VARIABLES Y TIPOS ---
echo -e "\n${YELLOW}PASO 2: Verificando Definición de Variables...${NC}"

# Validar que peso, altura e imc estén definidos como Real
if grep -qiE "Definir.*peso.*altura.*imc.*Como.*Real" "$FILE_PSC"; then
    echo -e "${GREEN}[OK] Variables (peso, altura, imc) definidas como Real.${NC}"
else
    echo -e "${RED}[ERROR] Las variables peso, altura e imc deben definirse como Real.${NC}"
    FAILED=1
fi

# --- PASO 3: VERIFICAR ESTRUCTURAS DE CONTROL ---
echo -e "\n${YELLOW}PASO 3: Verificando Estructuras de Control (Mientras y Si-Entonces)...${NC}"

# Validar uso de Mientras para validación (buscamos al menos dos ciclos)
MIENTRAS_COUNT=$(grep -ci "Mientras" "$FILE_PSC")
if [ "$MIENTRAS_COUNT" -ge 2 ]; then
    echo -e "${GREEN}[OK] Se detectaron ciclos 'Mientras' para validación.${NC}"
else
    echo -e "${RED}[ERROR] Se requieren al menos 2 ciclos 'Mientras' (uno para peso y otro para altura).${NC}"
    FAILED=1
fi

# Validar estructura Si-Entonces con operador lógico Y
if grep -qiE "Si.*imc.*>=.*18.5.*Y.*imc.*<=.*24.9.*Entonces" "$FILE_PSC"; then
    echo -e "${GREEN}[OK] Estructura Si-Entonces con validación de rango (Y) correcta.${NC}"
else
    echo -e "${RED}[ERROR] No se encontró la estructura lógica: Si imc >= 18.5 Y imc <= 24.9 Entonces.${NC}"
    FAILED=1
fi

# --- RESULTADO FINAL ---
echo -e "\n--------------------------------------------------------"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✔ ALGORITMO APROBADO${NC}"
    echo "El código cumple con la función, validaciones y lógica solicitada."
    exit 0
else
    echo -e "${RED}✘ EL ALGORITMO NO CUMPLE LOS REQUISITOS${NC}"
    echo "Revisa los errores marcados en rojo arriba."
    exit 1
fi
