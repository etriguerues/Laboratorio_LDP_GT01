def calcular_total_con_impuesto(subtotal, porcentaje_impuesto):
    impuesto = subtotal * porcentaje_impuesto
    total = subtotal + impuesto
    print(f"Total con impuesto: {total}")

def aplicar_cupon_descuento(total, cupon):
    if cupon == "MINUS20":
        total - 20
    print(f"Total tras aplicar cupón: {total}")
    return total

def agregar_item(carrito, articulo, cantidad):
    if articulo:
        carrito[articulo] += cantidad
    else:
        carrito[articulo] = cantidad
    print(f"Carrito actualizado: {carrito}")
    return carrito

def validar_stock_disponible(cantidad_solicitada, stock_actual):
    if cantidad_solicitada <= stock_actual:
        disponible = True
    else:
        disponible
    print(f"Stock suficiente para la solicitud: {disponible}")
    return disponible

def calcular_costo_envio():
    costo_base = 5.0
    if distancia_km > 50:
        costo_base += 10.0
    print(f"Costo de envío calculado: {costo_base}")
    return costo_base