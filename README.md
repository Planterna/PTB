# Prestige Trust Bank (PTB) 🏦📱
### Manual Técnico y Documentación de Arquitectura MVVM

Aplicación móvil bancaria corporativa (MVP) construida con **Flutter** bajo el patrón arquitectónico **MVVM (Model - View - ViewModel)**, conectada a un backend RESTful desplegado en la nube con **Node.js / Express**, **TypeScript**, **Prisma ORM** y **PostgreSQL**.

---

## 📑 Tabla de Contenidos (Rúbrica de Evaluación)

1. [Punto 1: Fase de Branding y Design System](#1-punto-1-fase-de-branding-y-design-system)
   - 1.1 Nombre Institucional y Logotipo
   - 1.2 Paleta de Colores Corporativos (`AppColors`)
   - 1.3 Tipografía y Cifras Tabulares (`AppTheme.amountStyle`)
   - 1.4 Radio de Bordes Estandarizado (Design Tokens de 14px)
2. [Punto 2: Vistas Principales y Experiencia de Usuario (UX/UI)](#2-punto-2-vistas-principales-y-experiencia-de-usuario-uxui)
   - 2.1 Registro (Creación de Usuario)
   - 2.2 Inicio de Sesión (Login)
   - 2.3 Dashboard (Pantalla Principal y Movimientos)
   - 2.4 Perfil de Usuario (Gestión y Control en 3 Categorías)
   - 2.5 Módulo de Pagos y Transferencias (Flujo por Pasos)
3. [Punto 3: Desarrollo Técnico en Flutter y Arquitectura MVVM](#3-punto-3-desarrollo-técnico-en-flutter-y-arquitectura-mvvm)
   - 3.1 Desglose de Capas MVVM (Model - View - ViewModel)
   - 3.2 Capa de Datos (DataSources y Repositorios)
   - 3.3 Widgets Personalizados y Componentes Reutilizables
   - 3.4 Navegación y Gestión de Flujos
   - 3.5 Optimización y Calidad de Código
   - 3.6 Compilación y Generación del APK
4. [Punto 4: Backend, Base de Datos e Integración REST](#4-punto-4-backend-base-de-datos-e-integración-rest)
   - 4.1 Repositorio y Despliegue del Backend
   - 4.2 Esquema de Base de Datos PostgreSQL (Prisma ORM)
   - 4.3 Catálogo de Endpoints RESTful
5. [Punto 5: Guía de Instalación y Ejecución](#5-punto-5-guía-de-instalación-y-ejecución)

---

## 1. Punto 1: Fase de Branding y Design System

La identidad corporativa de **Prestige Trust Bank (PTB)** fue concebida para transmitir seguridad, sobriedad y modernidad, propia de una entidad financiera de primer nivel.

### 1.1 Nombre Institucional y Logotipo
* **Nombre:** Prestige Trust Bank (PTB).
* **Identidad Vectorial:** Isotipo y logotipo oficial en formato SVG (`assets/logos/`) renderizados con `flutter_svg`, garantizando nitidez vectorial en cualquier densidad de pantalla (xxhdpi, tablets).

### 1.2 Paleta de Colores Corporativos (`AppColors`)
Centralizada en `lib/core/constants/app_colors.dart`:
* **Fondo:** `#000000` con gradientes radiales profundos a `#121A27` (*ambient glow* bancario).
* **Primario (Azul Hielo):** `#A4BCFC` — Empleado en botones principales, íconos de énfasis y bordes activos.
* **Secundario (Celeste Suave):** `#CDE7FC` — Textos de realce y fondos de acento.
* **Acento (Verde Menta):** `#A7DBCB` — Indicadores de éxito, validaciones correctas y balances monetarios.
* **Superficies:** `#14171D` (`AppColors.surface`) y `#1C2028` (`AppColors.surfaceLight`) para tarjetas y campos.
* **Peligro / Alerta:** `#FF8A8A` (`AppColors.danger`) para bordes de error y mensajes de validación.

### 1.3 Tipografía y Cifras Tabulares (`AppTheme.amountStyle`)
* **Fuente Principal:** Google Fonts Noto Sans aplicada globalmente en `ThemeData`.
* **Cifras Tabulares Numéricas:** Para evitar que los dígitos y decimales bailen al refrescar saldos, se implementó el método utilitario `AppTheme.amountStyle(...)` con `FontFeature.tabularFigures()`, garantizando números de ancho fijo y perfecta alineación en balances, movimientos y montos de transferencias.

### 1.4 Radio de Bordes Estandarizado (Design Tokens de 14px)
Para asegurar consistencia visual en toda la aplicación:
* `AppTheme.cardRadius = 14.0`
* `AppTheme.buttonRadius = 14.0`
* Aplicado uniformemente en tarjetas (`BankCardWidget`, `AccountCardWidget`), inputs (`CustomTextField`), diálogos modales, contenedores de vidrio y botones.

---

## 2. Punto 2: Vistas Principales y Experiencia de Usuario (UX/UI)

### 2.1 Registro (Creación de Usuario) — `lib/ui/views/register_view.dart`
* **Reducción de Carga Cognitiva:** Formulario dividido en 2 bloques claramente jerarquizados:
  1. *Datos Personales:* Cédula y Nombres Completos.
  2. *Credenciales de Acceso:* Correo Electrónico, Contraseña y Confirmación.
* **Validaciones Visuales en Tiempo Real:** Los campos cambian de color dinámicamente al escribir:
  * **Válido:** Borde verde menta (`#A7DBCB`) con ícono de verificación en el sufijo.
  * **Inválido:** Borde rojo suave (`#FF8A8A`) con texto de advertencia claro.
  * **En foco:** Borde primario (`#A4BCFC`).
* **Íconos de Prefijo Sutiles:** Íconos distintivos contextuales en cada campo (`badge_outlined`, `person_outline`, `email_outlined`, `lock_outlined`).
* **Conexión REST:** Envía `POST /api/auth/register` verificando unicidad de cédula y correo en PostgreSQL.

### 2.2 Inicio de Sesión (Login) — `lib/ui/views/login_view.dart`
* **Fondo con Gradientes Suaves:** Atmósfera oscura con degradado radial sutil (*ambient glow*) que otorga profundidad tridimensional.
* **Jerarquía Visual:** Botón de acceso de ancho completo con estado de carga reactivo (`CircularProgressIndicator`).
* **Sesión Segura y Persistente:** Tras autenticación exitosa contra `POST /api/auth/login`, almacena el token JWT y los datos del usuario en `SharedPreferences` para mantener la sesión activa.

### 2.3 Dashboard (Pantalla Principal) — `lib/ui/views/home_view.dart`
* **Efecto de Vidrio Esmerilado (*Frosted Glass / Glassmorphism*):** Implementado mediante el componente `GlassContainer` (`BackdropFilter` con desenfoque gaussiano y bordes translúcidos) en tarjetas de resumen y filtros.
* **Lista de Movimientos Virtualizada:** Reemplazo de columnas estáticas por `CustomScrollView` + `SliverList.builder`, cargando transacciones por demanda para máximo rendimiento en listas extensas.
* **Categorías de Consumo e Iconografía:** Cada transacción cuenta con su etiqueta visual de categoría (*Comida, Salud, Ocio, Compras, Transferencia*) e ícono temático correspondiente (`Icons.restaurant`, `Icons.medical_services`, `Icons.sports_esports`, etc.).
* **Estados Pulidos:** *Empty state* con ilustración bancaria cuando no existen transacciones y estado de error con botón de reintento.

### 2.4 Perfil de Usuario (Gestión y Control) — `lib/ui/views/settings_view.dart`
Organizada estrictamente en las tres categorías requeridas:
1. **DATOS:** Consulta de información personal (Nombre, Cédula, Correo) con modal de edición interactivo que valida en tiempo real y persiste las modificaciones.
2. **SEGURIDAD:** Control de contraseña, biometría y sesiones activas.
3. **CERRAR SESIÓN:** Diálogo de confirmación que purga completamente el token JWT y claves de sesión en `SharedPreferences`, redirigiendo de forma segura al Login.
* **Prevención de Desbordamiento:** Maquetado con scroll elástico (`BouncingScrollPhysics`) para evitar errores de `RenderFlex overflow`.

### 2.5 Módulo de Pagos y Transferencias — `lib/ui/views/payments_view.dart`
Rediseñado bajo un **flujo guiado de 2 pasos minimalista**:
* **Paso 1: Validación de Cuenta Destino:**
  * Selector tipo *Segmented Control* entre **Prestige Bank** (Mismo Banco) y **Otro Banco** (Selector de bancos interbancarios: Pichincha, Guayaquil, Produbanco, etc.).
  * Tipo de cuenta: *Ahorros* o *Corriente*.
  * Restricción estricta de **10 dígitos numéricos** con formateadores (`digitsOnly`, `LengthLimiting(10)`).
  * **Cápsulas de Prueba Rápida (Filtros Horizontales):** Chips compactos para probar en un toque cuentas quemadas (*Carlos Mendoza*, *María Rodríguez*, *Esteban Morales*).
  * Validación reactiva y visualización de la tarjeta de beneficiario verificado.
* **Paso 2: Monto y Transferencia:**
  * Selector de cuenta origen con saldo disponible.
  * Campo de monto con tipografía tabular de 28px y el símbolo `$` alineado milimétricamente en la misma línea base.
  * Chips rápidos de incremento (`+$10`, `+$25`, `+$50`, `+$100`).
  * Generación de **Comprobante Digital Oficial** de transferencia con número de referencia, fecha, montos y datos del beneficiario.

---

## 3. Punto 3: Desarrollo Técnico en Flutter y Arquitectura MVVM

El proyecto implementa la arquitectura **MVVM (Model - View - ViewModel)** para desacoplar totalmente la lógica de negocio de la interfaz de usuario:

```
┌────────────────────────────────────────────────────────────────────────┐
│                                 VIEW                                   │
│  (LoginView, RegisterView, HomeView, SettingsView, PaymentsView)       │
│  - Widgets declarativos de Flutter                                     │
│  - Escucha cambios mediante ListenableBuilder                          │
│  - Notifica eventos de usuario al ViewModel                            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Invoca métodos / Dispara acciones
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                              VIEWMODEL                                 │
│  (LoginViewModel, RegisterViewModel, HomeViewModel, ProfileViewModel) │
│  - Extiende de ChangeNotifier                                          │
│  - Mantiene el estado de la UI (isLoading, errorMessage, datos)        │
│  - Emite notifyListeners() ante cambios de estado                      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Solicita datos procesados
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                             REPOSITORY                                 │
│  (AuthRepository, FinanceRepository, UserRepository)                   │
│  - Coordina fuentes de datos remotas y locales                         │
│  - Abstrae el protocolo HTTP de la lógica de negocio                   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Consume endpoints REST / Almacén
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                         REMOTE DATASOURCES                             │
│  (RemoteAuthDataSource, RemoteFinanceDataSource, RemoteUserDataSource) │
│  - Cliente HTTP con serialización JSON                                 │
│  - Gestión de cabeceras de autorización Bearer JWT                     │
│  - Modelos Inmutables (UserModel, AccountModel, CardModel, etc.)       │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Desglose de Capas MVVM

#### A. Modelos (`lib/data/models/`)
Clases puras inmutables, responsables de la serialización y tipado fuerte:
* `UserModel`: Identificador, cédula, nombres y correo electrónico.
* `AccountModel`: ID de cuenta, tipo (`ahorro`/`corriente`), número y saldo.
* `CardModel`: ID de tarjeta, tipo (`debito`/`credito`), máscara y nombre impreso.
* `TransactionModel`: ID, valor, fecha, tipo y categoría enriquecida (`displayCategory`).

#### B. ViewModels (`lib/ui/viewmodels/`)
Controladores reactivos desacoplados de `BuildContext`:
* `LoginViewModel`: Maneja credenciales, estado de carga y almacenamiento de sesión.
* `RegisterViewModel`: Gobierna las validaciones en dos fases y creación del usuario.
* `HomeViewModel`: Orquesta la carga concurrente de cuentas, tarjetas y movimientos con `Future.wait`, además de los filtros de transacciones.
* `ProfileViewModel`: Administra la consulta y actualización de datos personales y la purga de sesión en el logout.

#### C. Vistas (`lib/ui/views/`)
Estructuras puramente declarativas que se reconstruyen granularmente con `ListenableBuilder`, evitando renders innecesarios.

### 3.2 Capa de Datos (DataSources y Repositorios)
* `RemoteAuthDataSource`: Consume `/api/auth/login` y `/api/auth/register`, y gestiona el ciclo de vida del JWT en `SharedPreferences`.
* `RemoteFinanceDataSource`: Realiza peticiones autenticadas para cuentas, tarjetas y movimientos bancarios.
* `RemoteUserDataSource`: Consume `/api/usuario/perfil` con respaldo sincronizado en sesión persistente.
* `AuthRepository`, `FinanceRepository`, `UserRepository`: Proveen métodos limpios a los ViewModels abstrayéndolos de la red.

### 3.3 Widgets Personalizados y Componentes Reutilizables
* `GlassContainer`: Contenedor de vidrio esmerilado con desenfoque gaussiano ajustable.
* `CustomTextField`: Campo de texto estilizado con validaciones en tiempo real y soporte de íconos de prefijo.
* `AccountCardWidget`: Tarjeta de cuenta bancaria con opción de ocultar/mostrar saldo.
* `BankCardWidget`: Tarjeta plástica física (Débito/Crédito) con degradados premium.
* `TransactionItemWidget`: Elemento de lista con ícono contextual y chip de categoría.
* `NotificationHelper`: Notificaciones flotantes tipo snackbar corporativas.

### 3.4 Navegación y Gestión de Flujos
* Enrutamiento controlado sin fugas en la pila de pantallas (`Navigator.pushReplacement` en login y logout).
* Barra de navegación inferior interactiva (`BottomNavBarWidget`) con 3 pestañas principales: **Inicio**, **Pagos** y **Ajustes**.

### 3.5 Optimización y Calidad de Código
* **0 errores y 0 advertencias:** Verificado exhaustivamente con `dart analyze lib` y `flutter analyze`.
* **Cero datos mockeados en producción:** Repositorios desacoplados de mocks locales, operando contra el backend REST.
* **Manejo Seguro de Contextos:** Verificación estricta de `mounted` antes de utilizar `BuildContext` a través de brechas asíncronas.

### 3.6 Compilación y Generación del APK
* **Permiso de Internet configurado** en `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
* **Comando para compilar el APK Release:**
  ```bash
  flutter build apk --release
  ```
* **Ruta del artefacto resultante:**
  `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Punto 4: Backend, Base de Datos e Integración REST

### 4.1 Repositorio y Despliegue del Backend
* **Repositorio en GitHub:** [https://github.com/Planterna/PTB-Backend](https://github.com/Planterna/PTB-Backend)
* **API Desplegada en Producción:** [https://ptbbackend.vercel.app/api](https://ptbbackend.vercel.app/api)
* **Tecnologías:** Node.js, Express, TypeScript, Prisma ORM, JSON Web Tokens (JWT) y bcrypt.

### 4.2 Esquema de Base de Datos PostgreSQL (Prisma ORM)
```prisma
model Usuario {
  id_usuario       String        @id @default(uuid())
  cedula_usuario   String        @unique @db.VarChar(10)
  nombres_usuario  String        @db.VarChar(255)
  email_usuario    String        @unique @db.VarChar(255)
  password_usuario String        @db.VarChar(255)
  cuentas          Cuenta[]
  tarjetas         Tarjeta[]
  movimientos      Movimiento[]
}

model Cuenta {
  id_cuenta     String        @id @default(uuid())
  id_usuario    String
  tipo_cuenta   TipoCuenta    @default(ahorro)
  numero_cuenta String        @unique @db.VarChar(10)
  saldo_cuenta  Float         @default(0.0)
  usuario       Usuario       @relation(fields: [id_usuario], references: [id_usuario])
  tarjetas      Tarjeta[]
  movimientos   Movimiento[]
}

model Tarjeta {
  id_tarjeta     String      @id @default(uuid())
  id_usuario     String
  id_cuenta      String
  nombre_tarjeta String      @db.VarChar(100)
  numero_tarjeta String      @unique @db.VarChar(20)
  tipo_tarjeta   TipoTarjeta
  usuario        Usuario     @relation(fields: [id_usuario], references: [id_usuario])
  cuenta         Cuenta      @relation(fields: [id_cuenta], references: [id_cuenta])
}

model Movimiento {
  id_movimiento     String         @id @default(uuid())
  id_usuario        String
  id_cuenta         String
  nombre_movimiento String         @db.VarChar(255)
  valor_movimiento  Float
  tipo_movimiento   TipoMovimiento
  fecha_movimiento  DateTime       @default(now())
  usuario           Usuario        @relation(fields: [id_usuario], references: [id_usuario])
  cuenta            Cuenta         @relation(fields: [id_cuenta], references: [id_cuenta])
}
```

### 4.3 Catálogo de Endpoints RESTful

| Método | Endpoint | Descripción | Autenticación |
|---|---|---|:---:|
| `POST` | `/api/auth/register` | Registro de nuevo cliente bancario | Pública |
| `POST` | `/api/auth/login` | Autenticación y expedición de token JWT | Pública |
| `GET` | `/api/cuentas` | Consulta de cuentas de ahorros/corrientes | Bearer JWT |
| `POST` | `/api/cuentas` | Apertura de una nueva cuenta corriente | Bearer JWT |
| `GET` | `/api/tarjetas` | Consulta de tarjetas plásticas vinculadas | Bearer JWT |
| `POST` | `/api/tarjetas` | Solicitud y emisión de tarjeta de crédito | Bearer JWT |
| `GET` | `/api/movimientos` | Historial de transacciones financieras | Bearer JWT |
| `GET` | `/api/usuario/perfil` | Consulta del perfil de usuario autenticado | Bearer JWT |
| `PUT` | `/api/usuario/perfil` | Actualización de datos personales | Bearer JWT |

---

## 5. Punto 5: Guía de Instalación y Ejecución

### 5.1 Requisitos del Sistema
* **Flutter SDK:** `>= 3.13.5` (Canal Stable).
* **Dart SDK:** `>= 3.1.0`.
* **Dispositivo:** Emulador Android (API 28+) o dispositivo móvil físico con Depuración USB.

### 5.2 Pasos para Ejecutar el Frontend
1. Clonar el repositorio localmente:
   ```bash
   git clone https://github.com/Planterna/PTB.git
   cd PTB
   ```
2. Descargar paquetes y dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Verificar análisis estático de código:
   ```bash
   dart analyze lib
   ```
4. Ejecutar en emulador o dispositivo conectado:
   ```bash
   flutter run
   ```

### 5.3 Pasos para Ejecutar el Backend en Local (Opcional)
1. Clonar el repositorio del backend:
   ```bash
   git clone https://github.com/Planterna/PTB-Backend.git
   cd PTB-Backend
   ```
2. Instalar dependencias:
   ```bash
   npm install
   ```
3. Configurar variables de entorno en el archivo `.env`:
   ```env
   PORT=3000
   DATABASE_URL="postgresql://usuario:password@localhost:5432/ptb_db?schema=public"
   JWT_SECRET="clave_secreta_jwt_bancaria"
   ```
4. Migrar e iniciar el servidor:
   ```bash
   npx prisma db push
   npm run dev
   ```
5. Documentación interactiva Swagger en: `http://localhost:3000/api/docs`.
