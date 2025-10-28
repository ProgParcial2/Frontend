# Instrucciones para Agentes AI - Frontend Marketplace Flutter

## Arquitectura y Estructura

Este es un frontend de marketplace desarrollado en Flutter que sigue una arquitectura cliente-servidor con las siguientes características clave:

### Componentes Principales
- **API Client** (`lib/main.dart` clase `Api`): Cliente HTTP singleton que maneja todas las comunicaciones con el backend
- **Autenticación**: Sistema de tokens JWT para autenticación de usuarios
- **Roles**: Soporte para dos tipos de usuarios: `empresa` y `cliente`
- **Estados de Órdenes**: Sistema de estados para órdenes (`nuevo`, `enviado`, `entregado`, `cancelado`)

### Patrones y Convenciones
1. **API Singleton**
   ```dart
   // Uso correcto del singleton API
   Api.I.metodo()  // ✓ Correcto
   Api().metodo()  // ✗ Incorrecto
   ```

2. **Manejo de Estados**
   - Usar el enum `OrderStatus` para estados de órdenes
   - Convertir estados a strings usando `statusToStr()`

3. **Endpoints Backend**
   - Base URL: `https://tu-backend.azurewebsites.net`
   - Autenticación: Bearer token en header `Authorization`
   - Formato de respuestas: JSON con `items` para listas

## Flujos de Desarrollo

### Configuración del Entorno
1. Versión SDK Flutter requerida: ^3.9.2
2. Dependencias principales:
   - http: ^1.2.0 (cliente HTTP)
   - cupertino_icons: ^1.8.0 (iconos iOS)

### Comandos Esenciales
```bash
flutter pub get     # Instalar dependencias
flutter run        # Ejecutar app en modo desarrollo
flutter build      # Construir para producción
```

## Patrones de Integración

### Comunicación con Backend
1. **Autenticación**
   ```dart
   await Api.I.login(email, password);
   ```

2. **Consultas con Filtros**
   ```dart
   await Api.I.listProducts(
     companyId: '123',
     minPrice: 10.0,
     maxPrice: 100.0
   );
   ```

### Buenas Prácticas
- Siempre manejar errores HTTP en las llamadas a la API
- Usar el modelo Material3 con el esquema de colores definido
- Mantener la estructura de directorio lib/ organizada por funcionalidad

## Recursos Clave
- `lib/main.dart`: Punto de entrada y configuración principal
- `pubspec.yaml`: Gestión de dependencias y assets