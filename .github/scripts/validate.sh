#!/bin/bash
# =====================================================================
# SCRIPT DE CALIFICACIÓN AUTOMÁTICA CON ANÁLISIS AST DOBLE: E-COMMERCE PRO
# =====================================================================
export LANG=C.UTF-8

# Aprovisionamiento express del motor de testing
echo "Preparando dependencias..."
python3 -m pip install pytest --user -q

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0;0m' 
FAILED=0

echo -e "\n=========================================================="
echo "Iniciando Evaluación Dinámica y Estructural (AST)"
echo -e "==========================================================\n"

# ---------------------------------------------------------
# FASE 0: Verificación de Existencia de Archivos
# ---------------------------------------------------------
ARCHIVOS_REQUERIDOS=("carrito_pro.py" "test_carrito_pro.py")
FALTAN_ARCHIVOS=0

for archivo in "${ARCHIVOS_REQUERIDOS[@]}"; do
    if [ ! -f "$archivo" ]; then
        echo -e "${RED}✘ [FASE 0 - ERROR]: No se encontró el archivo obligatorio: '$archivo'.${NC}"
        FALTAN_ARCHIVOS=1
    fi
done

if [ $FALTAN_ARCHIVOS -ne 0 ]; then
    echo -e "\n${RED}ESTADO DE EVALUACIÓN: RECHAZADA (0/100). Faltan archivos críticos para iniciar la evaluación.${NC}"
    echo -e "=========================================================="
    exit 1
else
    echo -e "${GREEN}✔ [FASE 0 - ARCHIVOS]: Archivos base y de pruebas localizados correctamente.${NC}"
fi

# ---------------------------------------------------------
# FASE 1: Análisis Estático Básico
# ---------------------------------------------------------
if python3 -m py_compile "carrito_pro.py" 2>/dev/null; then
    echo -e "${GREEN}✔ [FASE 1 - COMPILACIÓN]: Sin errores de sintaxis.${NC}"
else
    echo -e "${RED}✘ [FASE 1 - CRÍTICA]: Error fatal de sintaxis en carrito_pro.py.${NC}"
    exit 1
fi

# ---------------------------------------------------------
# FASE 2: Análisis Estructural Estricto (AST Base)
# ---------------------------------------------------------
# Generamos un script de Python al vuelo para analizar el código del alumno
cat << 'EOF' > ast_validator.py
import ast
import sys

def validar_estructura(archivo):
    try:
        with open(archivo, 'r', encoding='utf-8') as f:
            tree = ast.parse(f.read())
    except Exception as e:
        print(f"✘ [AST ERROR] No se pudo parsear el archivo: {e}")
        sys.exit(1)

    # 1. Extraer todas las funciones definidas en el archivo
    funciones = {node.name: node for node in ast.walk(tree) if isinstance(node, ast.FunctionDef)}
    
    requeridas = [
        "importar_y_validar_orden",
        "gestionar_historial_carrito",
        "escanear_estanteria_bodega",
        "calcular_descuento_cascada",
        "ordenar_productos_quicksort",
        "buscar_precio_binario"
    ]

    errores = []

    # 2. Validar Nombres de Funciones
    for req in requeridas:
        if req not in funciones:
            errores.append(f"Falta la función requerida o nombre incorrecto: '{req}'")

    if errores:
        for err in errores: print(f"✘ [ESTRUCTURA]: {err}")
        sys.exit(1)

    # 3. Validaciones de Elementos Gramaticales por Módulo
    
    # buscar_precio_binario: Debe usar While, If, Assign (Variables) y Return
    f_binaria = funciones["buscar_precio_binario"]
    if not any(isinstance(n, ast.While) for n in ast.walk(f_binaria)):
        errores.append("buscar_precio_binario debe usar un ciclo 'while'.")
    if not any(isinstance(n, ast.If) for n in ast.walk(f_binaria)):
        errores.append("buscar_precio_binario debe usar condicionales ('if'/'elif'/'else').")

    # escanear_estanteria_bodega: Debe usar For
    f_bodega = funciones["escanear_estanteria_bodega"]
    if not any(isinstance(n, ast.For) for n in ast.walk(f_bodega)):
        errores.append("escanear_estanteria_bodega debe usar ciclos 'for'.")

    # ordenar_productos_quicksort: Debe usar listas
    f_quick = funciones["ordenar_productos_quicksort"]
    if not any(isinstance(n, (ast.List, ast.ListComp)) for n in ast.walk(f_quick)):
        errores.append("ordenar_productos_quicksort debe utilizar Listas o Listas por comprensión (DRY).")

    # Validaciones Globales Críticas (Variables y Returns)
    for nombre_func, nodo_func in funciones.items():
        if nombre_func in requeridas:
            if not any(isinstance(n, ast.Assign) for n in ast.walk(nodo_func)):
                errores.append(f"La función '{nombre_func}' no declara ninguna variable.")
            if not any(isinstance(n, ast.Return) for n in ast.walk(nodo_func)):
                errores.append(f"La función '{nombre_func}' no contiene la instrucción 'return'.")

    if errores:
        for err in errores: print(f"✘ [INCUMPLIMIENTO TÉCNICO]: {err}")
        sys.exit(1)

    print("✔ [FASE 2 - AST BASE]: Nombres, ciclos, condicionales, listas y retornos validados.")
    sys.exit(0)

if __name__ == '__main__':
    validar_estructura("carrito_pro.py")
EOF

# Ejecutar el validador AST Base
if python3 ast_validator.py; then
    rm ast_validator.py # Limpiamos el archivo temporal
else
    rm ast_validator.py
    echo -e "${RED}✘ [FASE 2 - CRÍTICA]: El código no usa las estructuras requeridas en las instrucciones.${NC}"
    exit 1
fi

# ---------------------------------------------------------
# FASE 3: Análisis Estructural Estricto de Pruebas (AST Tests)
# ---------------------------------------------------------
cat << 'EOF' > ast_test_validator.py
import ast
import sys

test_file = "test_carrito_pro.py"

try:
    with open(test_file, 'r', encoding='utf-8') as f:
        tree = ast.parse(f.read())
except Exception as e:
    print(f"✘ [AST TESTS ERROR] No se pudo parsear {test_file}: {e}")
    sys.exit(1)

has_pytest = False
imported_funcs = set()

# Escanear el AST buscando Imports
for node in ast.walk(tree):
    if isinstance(node, ast.Import):
        for alias in node.names:
            if alias.name == 'pytest':
                has_pytest = True
    elif isinstance(node, ast.ImportFrom):
        if node.module in ['carrito', 'carrito_pro']:
            for alias in node.names:
                imported_funcs.add(alias.name)

requeridas = {
    "importar_y_validar_orden", "gestionar_historial_carrito",
    "escanear_estanteria_bodega", "calcular_descuento_cascada",
    "ordenar_productos_quicksort", "buscar_precio_binario"
}

errores = []
if not has_pytest:
    errores.append("Falta la instrucción obligatoria: 'import pytest'.")

faltantes = requeridas - imported_funcs
if faltantes:
    errores.append(f"Faltan importar funciones desde el archivo base: {', '.join(faltantes)}")

if errores:
    for err in errores: print(f"✘ [TRAMPA DETECTADA EN TESTS]: {err}")
    sys.exit(1)

print("✔ [FASE 3 - AST TESTS]: Importación de dependencias (pytest) y funciones validada exitosamente.")
sys.exit(0)
EOF

# Ejecutar el validador AST de Tests
if python3 ast_test_validator.py; then
    rm ast_test_validator.py
else
    rm ast_test_validator.py
    echo -e "${RED}✘ [FASE 3 - CRÍTICA]: El archivo de pruebas no importa los elementos requeridos.${NC}"
    exit 1
fi

# ---------------------------------------------------------
# FASE 4: Pruebas Unitarias de Lógica de Negocio
# ---------------------------------------------------------
echo "----------------------------------------------------------"
echo "Lanzando aserciones lógicas mediante Pytest..."

if pytest test_carrito_pro.py -q -s; then
    echo -e "${GREEN}✔ [FASE 4 - COMPORTAMIENTO]: Lógica de negocio y Big O validados.${NC}"
else
    echo -e "${RED}✘ [FASE 4 - FALLO LÓGICO]: Falló uno o más casos de prueba de Pytest.${NC}"
    FAILED=1
fi

echo -e "\n=========================================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}ESTADO DE EVALUACIÓN: PASADA (100/100)${NC}"
    exit 0
else
    echo -e "${RED}ESTADO DE EVALUACIÓN: RECHAZADA (0/100). Revisa las trazas superiores.${NC}"
    exit 1
fi
echo -e "=========================================================="
