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

    # Validar Nombres de Funciones
    for req in requeridas:
        if req not in funciones:
            errores.append(f"Falta la función requerida o nombre incorrecto: '{req}'")

    if errores:
        for err in errores: print(f"✘ [ESTRUCTURA]: {err}")
        sys.exit(1)

    # ----------------------------------------------------------------
    # Validaciones Específicas por Función (Basado en la Rúbrica)
    # ----------------------------------------------------------------

    # 1. importar_y_validar_orden: Validar Try/Except
    f_importar = funciones["importar_y_validar_orden"]
    if not any(isinstance(n, ast.Try) for n in ast.walk(f_importar)):
        errores.append("importar_y_validar_orden debe usar un bloque 'try' y 'except'.")

    # 2. gestionar_historial_carrito: Validar if, elif, append y pop
    f_historial = funciones["gestionar_historial_carrito"]
    if not any(isinstance(n, ast.If) for n in ast.walk(f_historial)):
        errores.append("gestionar_historial_carrito debe usar 'if'.")
    # En el AST, un elif o else se detecta validando que el nodo If tenga un bloque orelse
    if not any(isinstance(n, ast.If) and n.orelse for n in ast.walk(f_historial)):
        errores.append("gestionar_historial_carrito debe usar 'elif' o 'else'.")
    
    llamadas_metodos = [n.func.attr for n in ast.walk(f_historial) if isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute)]
    if 'append' not in llamadas_metodos:
        errores.append("gestionar_historial_carrito debe usar la función 'append'.")
    if 'pop' not in llamadas_metodos:
        errores.append("gestionar_historial_carrito debe usar la función 'pop'.")

    # 3. escanear_estanteria_bodega: Validar For
    f_bodega = funciones["escanear_estanteria_bodega"]
    if not any(isinstance(n, ast.For) for n in ast.walk(f_bodega)):
        errores.append("escanear_estanteria_bodega debe usar ciclos 'for'.")

    # 4. calcular_descuento_cascada: Validar If
    f_descuento = funciones["calcular_descuento_cascada"]
    if not any(isinstance(n, ast.If) for n in ast.walk(f_descuento)):
        errores.append("calcular_descuento_cascada debe usar la estructura condicional 'if'.")

    # 5. ordenar_productos_quicksort: Validar uso de corchetes para Listas
    f_quick = funciones["ordenar_productos_quicksort"]
    if not any(isinstance(n, (ast.List, ast.ListComp)) for n in ast.walk(f_quick)):
        errores.append("ordenar_productos_quicksort debe utilizar corchetes para listas [ ].")

    # 6. buscar_precio_binario: Validar While
    f_binaria = funciones["buscar_precio_binario"]
    if not any(isinstance(n, ast.While) for n in ast.walk(f_binaria)):
        errores.append("buscar_precio_binario debe usar un ciclo 'while'.")

    # Validación Global: Todas deben retornar algo
    for nombre_func, nodo_func in funciones.items():
        if nombre_func in requeridas:
            if not any(isinstance(n, ast.Return) for n in ast.walk(nodo_func)):
                errores.append(f"La función '{nombre_func}' no contiene la instrucción 'return'.")

    # Emisión de Errores Final
    if errores:
        for err in errores: print(f"✘ [INCUMPLIMIENTO TÉCNICO]: {err}")
        sys.exit(1)

    print("\033[0;32m✔ [FASE 2 - AST BASE]: Reglas específicas de If, Elif, For, While, Try/Except, [] y mutaciones validadas.\033[0;0m")
    sys.exit(0)

if __name__ == '__main__':
    validar_estructura("carrito_pro.py")
EOF

if python3 ast_validator.py; then
    rm ast_validator.py
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

print("\033[0;32m✔ [FASE 3 - AST TESTS]: Importación de dependencias (pytest) y funciones validada exitosamente.\033[0;0m")
sys.exit(0)
EOF

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
