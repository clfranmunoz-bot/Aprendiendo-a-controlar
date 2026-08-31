# Manual de Usuario - Aprender a Controlar

Bienvenido al manual oficial de **Aprender a Controlar**, la aplicación móvil desarrollada en Flutter orientada a la capacitación, entrenamiento y apoyo operacional de controladores de sondajes en faenas mineras.

Este documento te guiará paso a paso sobre cómo funciona la aplicación, desde el sistema de control de acceso mensual hasta el uso de las calculadoras de terreno y el simulador de cuaderno.

---

## 📋 Índice
1. [Introducción y Objetivos](#1-introducción-y-objetivos)
2. [Control de Acceso y Seguridad](#2-control-de-acceso-y-seguridad)
   - [Acceso por Contraseña Rotativa](#acceso-por-contraseña-rotativa)
   - [Bloqueo de Seguridad](#bloqueo-de-seguridad)
   - [Re-validación de 28 Días](#re-validación-de-28-días)
3. [Flujo de Trabajo Operacional en Terreno](#3-flujo-de-trabajo-operacional-en-terreno)
   - [Antes de Perforar (Inicio de Turno)](#antes-de-perforar-inicio-de-turno)
   - [Durante la Perforación (Registro de Corridas)](#durante-la-perforación-registro-de-corridas)
   - [Cierre de Turno](#cierre-de-turno)
4. [Guía de Pantallas y Módulos](#4-guía-de-pantallas-y-módulos)
   - [Inicio Personalizable y Perfiles](#inicio-personalizable-y-perfiles)
   - [Calculadoras Operacionales](#calculadoras-operacionales)
   - [Simulador de Cuaderno de Terreno](#simulador-de-cuaderno-de-terreno)
   - [Cámara con Checklist de Campo](#cámara-con-checklist-de-campo)
   - [Módulo de Checklist de Turno](#módulo-de-checklist-de-turno)
   - [Asistente Virtual (DrillBot)](#asistente-virtual-drillbot)
   - [Panel de Instructor y Estadísticas](#panel-de-instructor-y-estadísticas)
5. [Fórmulas y Conceptos Técnicos](#5-fórmulas-y-conceptos-técnicos)

---

## 1. Introducción y Objetivos

La precisión en la medición del testigo y el cálculo de la profundidad del pozo son fundamentales para garantizar la calidad geológica y operacional del sondaje diamantino. **Aprender a Controlar** funciona como un simulador y entrenador personal diseñado para que:
* **Operadores Nuevos** dominen los procedimientos paso a paso y pierdan el miedo a los cálculos matemáticos de terreno.
* **Controladores Experimentados** tengan herramientas de cálculo rápido y checklists digitales para no omitir ningún protocolo de seguridad.
* **Instructores / Supervisores** monitoreen el progreso, nivel de precisión y cantidad de simulaciones completadas por su personal a cargo.

---

## 2. Control de Acceso y Seguridad

Para garantizar un uso autorizado y seguro en faena, la aplicación cuenta con un doble mecanismo de seguridad local (sin necesidad de internet).

### Acceso por Contraseña Rotativa
El acceso a la aplicación está protegido por una contraseña que rota mensualmente de forma cíclica.
* **Obtención de la clave:** El Administrador del Sistema o Supervisor de Faena es el encargado de proveer la contraseña correspondiente al mes en curso.
* **Vigencia:** Una vez ingresada la contraseña correcta del mes, la aplicación permanecerá desbloqueada y lista para operar durante todo ese mes calendario sin requerir volver a ingresarla.

> [!IMPORTANT]
> Las contraseñas de acceso son confidenciales y se manejan directamente por la supervisión de faena. Nunca las escribas ni las compartas fuera del canal oficial autorizado.

### Bloqueo de Seguridad
* El sistema otorga un máximo de **3 intentos** para introducir la contraseña.
* Si se ingresa una contraseña incorrecta en 3 ocasiones consecutivas, la aplicación **se bloqueará permanentemente por seguridad**.
* *Desbloqueo:* En caso de bloqueo accidental, deberás contactar al Supervisor o Administrador de la plataforma para realizar la restauración de acceso autorizada.

### Re-validación Periódica (Ciclo de 28 Días)
Cada 28 días de uso continuo, el sistema solicitará una verificación de identidad mediante contraseña para asegurar que el dispositivo sigue en manos de personal autorizado.
* Solicita esta contraseña especial a tu Supervisor cuando la aplicación muestre la pantalla de validación temporal.

---

## 3. Flujo de Trabajo Operacional en Terreno

La aplicación incorpora una guía interactiva con la secuencia ideal que todo controlador de sondajes debe seguir en terreno, organizada en tres fases críticas:

### Antes de Perforar (Inicio de Turno)
1. **Traspaso de Turno:** Recibe formalmente la información del controlador saliente (fondo actual del pozo, barras abajo, contra actual y anomalías).
2. **Medición del Punto Muerto (PM):** Mide la distancia fija desde el collar del pozo hasta la marca de referencia del cabezal de perforación (típicamente entre 0.40 m y 1.20 m). Este valor es constante durante tu turno.
3. **Cálculo de Herramientas Totales (Sarta):** Verifica con el perforista el número de barras y la configuración del barril (largo del barril y si se está utilizando extensión Reflex).
4. **Seguridad / EPP / Charla:** Realiza la charla de 5 minutos con la cuadrilla, delimita el área activa de trabajo y ponte el EPP obligatorio.
5. **Preparación del Cuaderno:** Abre la hoja del día con el nombre del pozo, fecha, PM y las columnas listas para los datos.

### Durante la Perforación (Registro de Corridas)
1. **Leer la Contra:** Justo antes de comenzar a perforar la corrida, lee la marca en el cabezal con el barril apoyado suavemente en el fondo del pozo.
2. **Supervisar Extracción de Testigo:** Acompaña al ayudante al extraer el tubo interior. Verifica que no se golpee la laina y se manipule con cuidado.
3. **Mapear y Medir:** Coloca el testigo en la cuna de tendido, mídelo con cinta métrica y calcula el porcentaje de recuperación (%Rec).
4. **Calcular la Nueva Contra:** Si se completó el tramo sin agregar barras, resta el perforado a la contra anterior. Si se añadió una barra nueva, suma primero el largo de la barra antes de restar el perforado.
5. **Regularización y Tacos:** Instala el taco de madera rojo al final de la corrida y realiza la regularización colocando tacos en las marcas de metraje entero correspondientes.
6. **Agua de Retorno:** Controla permanentemente el porcentaje de retorno del agua. Si baja, avisa de inmediato al perforista.

### Cierre de Turno
1. **Fondo Final:** Calcula y confirma el fondo final cruzando la información de barras añadidas con la última contra medida.
2. **Rotulado de Cajas:** Comprueba que cada caja tenga el nombre del pozo, número correlativo de caja, metraje de inicio y fin (Desde/Hasta) y las flechas indicando el sentido de avance del pozo.
3. **Fotografías Oficiales:** Captura fotos nítidas y cenitales de cada caja con su respectivo taco rotulado usando la cámara de la aplicación.
4. **Firma y Traspaso:** Consolida los metrajes totales y la recuperación promedio del turno. Realiza el traspaso al turno entrante de forma transparente y firma la planilla.

---

## 4. Guía de Pantallas y Módulos

### Inicio Personalizable y Perfiles
* **Slots Personalizables:** En la pantalla principal puedes presionar prolongadamente los accesos directos (slots) para elegir qué módulos tener a mano según tus tareas más frecuentes (por ejemplo, Calculadoras, Checklist o Cuaderno).
* **Gestión de Perfiles:** En el menú lateral o el encabezado superior puedes añadir nuevos perfiles (ej. *"Operador Juan"*, *"Supervisor Carlos"*). Cada perfil guarda su propio progreso, estadísticas y estado del Cuaderno de Terreno de forma independiente.

### Calculadoras Operacionales
Ubicadas en la barra de navegación o el menú, te permiten resolver 5 cálculos esenciales:
1. **Recuperación:** Digita el tramo perforado y el testigo medido en metros para obtener el porcentaje exacto de recuperación (`%Rec`).
2. **Contra:** Permite calcular la contra esperada. Si el metraje perforado es mayor que la contra anterior, la calculadora te sugerirá automáticamente si se agregó una barra adicional (de 3.00 m o 2.90 m) y te guiará para corregir la cuenta.
3. **Fondo de Pozo:** Ingresa la cantidad de barras, el largo de cada una, el largo del barril con su extensión, el punto muerto (PM) y la contra actual para saber con precisión milimétrica la profundidad del pozo.
4. **Tramo Perforado:** Resta el metraje final del inicial (Desde / Hasta) o deduce el avance a través de la variación de la contra.
5. **Regularización:** Te indica a cuántos metros reales corresponde un punto en el pozo y cómo posicionar los tacos de madera cuando hay pérdidas de testigo o tramos sobredimensionados.

### Simulador de Cuaderno de Terreno
El módulo **"Cuaderno de Terreno"** es un simulador avanzado diseñado para entrenar de forma idéntica a la operación real.
* **Configuración del Pozo:** Al iniciar, se te asignará un pozo aleatorio con un metraje inicial, número de barras iniciales, largo de barra, PM y longitud de barril.
* **Modos de Dificultad:**
  * **Básico:** Se enfoca en cálculos estándar sin cambios imprevistos en la sarta o el barril.
  * **Intermedio:** Agrega eventos aleatorios como desgastes de sarta que obligan a cambiar el largo de barra (ej. cambiar barras de 3.00m a 2.90m) o cambios de barril muestreador a mitad del pozo.
* **Ingreso de Datos:** Debes ir fila por fila calculando y digitando los valores de **Desde**, **Hasta**, **Herramientas (Sarta)**, **Cantidad de Barras**, **Contra** y **Fondo de Pozo**.
* **Validación al Instante:** El simulador revisa cada casilla. Si cometes un error, la celda se marcará en rojo y te indicará la fórmula de corrección para que aprendas del error.
* **Herramientas de Apoyo:** Cuenta con una **Calculadora de Bolsillo** virtual integrada en pantalla para que no tengas que salir de la aplicación para hacer cuentas intermedias.

### Cámara con Checklist de Campo
Para evitar que se envíen fotos al cliente con datos incompletos en el taco de madera o la caja:
* Al abrir la cámara, se desplegará un **Checklist Obligatorio de 5 puntos**:
  1. ¿Está escrito el Nombre del Pozo?
  2. ¿Está registrado el Inicio y Fin de Metraje en el taco?
  3. ¿Están colocados los Tacos de Bloqueo?
  4. ¿Están instalados los Tacos de Regularización?
  5. ¿El Número de Bandeja está visible?
* **Bloqueo del Obturador:** El botón para tomar la foto solo se habilitará cuando hayas marcado los 5 checks afirmativamente.

### Módulo de Checklist de Turno
Lleva una bitácora persistente de tus actividades durante el día. Se divide en cuatro pestañas:
1. **Inicio de Turno:** Verificaciones de EPP, charla operacional y orden en la plataforma.
2. **Control Operativo:** Supervisión del pozo, retornos de agua y comportamiento del perforista.
3. **Protocolos Especiales:** Acciones ante atascamiento de sarta, pérdida total de retorno o fallas mecánicas.
4. **Cierre de Turno:** Limpieza final, almacenamiento de muestras, rotulación y entrega de planilla.

Al finalizar el turno, puedes exportar o compartir un informe resumido en formato texto o PDF para el Supervisor del proyecto.

### Asistente Virtual (DrillBot)
Un chatbot interactivo alimentado con el conocimiento operativo del proyecto:
* Puedes hacerle preguntas rápidas en lenguaje natural, tales como:
  * *"¿Cuánto mide una extensión Reflex?"* (Respuesta: 0.40 m)
  * *"¿Fórmula para calcular el fondo?"*
  * *"¿Qué es el Punto Muerto?"*
  * *"¿Cómo funciona el acceso mensual?"* (Te recordará las reglas de rotación sin revelar claves)
  * *"¿Qué hacer si se pierde el retorno?"*
* **Sugerencias Rápidas:** En la parte inferior del chat dispones de botones de acceso rápido para formular preguntas frecuentes con un solo toque.

### Panel de Instructor y Estadísticas
Permite al supervisor evaluar el desempeño de la cuadrilla:
* **Estadísticas de Perfil:** Muestra la precisión promedio (%) en los ejercicios matemáticos, total de simulaciones completadas y tiempo récord.
* **Panel de Instructor:** Reúne los perfiles creados en el dispositivo y muestra un ranking con el nivel de precisión y el estado del cuaderno de terreno de cada operador. Permite exportar los datos para el reporte de capacitación mensual.

---

## 5. Fórmulas y Conceptos Técnicos

A continuación, se listan las relaciones matemáticas que la aplicación valida en todos sus módulos:

### 1. Longitud de Herramientas Totales (Herr)
Representa el largo físico de la sarta armada en el pozo sin considerar las barras normales de perforación. Es la distancia desde la marca del cabezal hasta la punta del zapato del barril, restando la altura del punto muerto.
$$\text{Herr} = (\text{N}^{\circ}\text{ Barras} \times \text{Largo}) + \text{Barril} + \text{Extensión} - \text{PM}$$

### 2. Profundidad del Fondo del Pozo (Fondo)
Es la profundidad exacta a la que se encuentra la corona de perforación.
$$\text{Fondo} = \text{Herr} - \text{Contra} - \text{PM}$$
$$\text{Fondo} = \text{Fondo Anterior} + \text{Tramo Perforado}$$

### 3. Recuperación de Testigo (%Rec)
Proporción de roca sólida recuperada en la cuna respecto al avance real perforado por el barril.
$$\%\text{Rec} = \left( \frac{\text{Testigo Recuperado (m)}}{\text{Tramo Perforado (m)}} \right) \times 100$$
*(Operacionalmente se exige un mínimo de **85.00%** de recuperación. Valores menores deben justificarse en la bitácora).*

### 4. Actualización de Contra
* **Sin añadir barra nueva:**
  $$\text{Contra Actual} = \text{Contra Anterior} - \text{Tramo Perforado}$$
* **Con adición de barra nueva (ej. 3.00 m):**
  $$\text{Contra Ajustada} = \text{Contra Anterior} + \text{Largo de Barra}$$
  $$\text{Contra Actual} = \text{Contra Ajustada} - \text{Tramo Perforado}$$

---

*¡Usa la aplicación diariamente para afinar tus habilidades de control operacional y garantizar la excelencia técnica en la campaña de sondajes!*
