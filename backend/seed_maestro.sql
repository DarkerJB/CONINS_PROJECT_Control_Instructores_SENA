-- ============================================================
-- CONINS — SEED MAESTRO (solo datos base para recibir el Excel)
-- Generado 26/08/2026 a partir de seed_data.sql.
-- INCLUYE: usuarios/instructores, competencias, RAPs, programas,
--   instructor_competencias_habilitadas, lider_programa, ambientes.
-- EXCLUYE (planeacion, se carga desde el Excel): fichas, asignacion,
--   asignacion_competencia, asignacion_rap, horarios, alertas, notificaciones.
-- Uso demo: database.sql -> seed_maestro.sql -> sistema listo, SIN planeacion,
--   esperando el import del Excel del lider.
-- ============================================================

-- ============================================================
-- CONINS - Seed Data v6
-- Personal del CDMC relevante para alcance ADSO (07/2026)
-- Correos marcados con * son inferidos por patron institucional
--
-- CAMBIOS v6 (06/07/2026):
--  - Eliminado Paul Tamayo de usuario_roles (coordinacion medular,
--    fuera del alcance ADSO inicial — ver P26)
--  - Eliminados instructores medulares (Calzado/Cuero) de la tabla
--    instructores y de instructor_competencias_habilitadas
--  - Eliminados sus rol_id=4 de usuario_roles
--  - Eliminados Programa Calzado, competencias 3-4, RAPs 5-8, ficha 2
--  - Usuarios 5, 10, 11, 12 permanecen como personas CDMC pero sin
--    rol ni registro instructor (acceso denegado hasta expansion medular)
--
-- IMPORTANTE: Las secciones marcadas con [TEST DATA] contienen
-- datos ficticios para habilitar pruebas locales.
-- Reemplazar con datos reales del CDMC cuando esten disponibles.
-- ============================================================

USE conIns;

-- ============================================================
-- USUARIOS (ID 2-24; admin no existe en BD — se maneja via .env SUPER_USER)
-- ============================================================
INSERT IGNORE INTO usuarios (id, nombre, email, password) VALUES
-- 1. DIRECCION
(2, 'Dyron Javier Ramirez', 'djramirez@sena.edu.co', NULL),

-- 2. COORDINACION ACADEMICA
-- Rocio Medina: sin rol hasta implementacion de juicios evaluativos instructores ADSO
(3, 'Rocio del Pilar Medina Rojas', 'rpmedina@sena.edu.co', NULL),
(4, 'Leidy Johana Ruiz Cortes', 'ljruizc@sena.edu.co', NULL),
-- Paul Tamayo: permanece como persona CDMC sin rol en el sistema
-- (coordinacion medular, fuera del alcance ADSO inicial — ver P26)
(5, 'Paul Ernesto Tamayo Caviedes', 'ptamayo@sena.edu.co', NULL),

-- 3. INSTRUCTORES ADSO/TIC
(6, 'Juliana Gomez', 'jugomez@sena.edu.co', NULL),
(7, 'Andres Martinez Carvajal', 'amartinezc@sena.edu.co', NULL),
(8, 'Diego Gomez', 'digomez@sena.edu.co', NULL),
(9, 'Ronald Quintero', 'rquintero@sena.edu.co', NULL),

-- 4. INSTRUCTORES MEDULARES (Diseno/Cuero/Calzado)
-- Sin rol ni registro instructor hasta expansion linea medular (ver P26)
(10, 'Carlos Castaneda', 'ccastanedaa@sena.edu.co', NULL),
(11, 'Diana Velasco', 'dvelascoa@sena.edu.co', NULL),
(12, 'Edilberto Fontecha', 'edfontecha@sena.edu.co', NULL),

-- 5. INSTRUCTORES TRANSVERSALES
(13, 'Sol Beatriz Castano', 'sbcastano@sena.edu.co', NULL),
(14, 'Laura Gallego', 'lgallego@sena.edu.co', NULL),
(15, 'Jose Luis Cardona', 'jlcardona@sena.edu.co', NULL),
(16, 'Sandra Velasquez', 'svelasquez@sena.edu.co', NULL),

-- 6. ADMINISTRATIVOS (sin rol de instructor)
(17, 'Maria Morales Moreno', 'hmmorales@sena.edu.co', NULL),
(18, 'Juan David Tamayo Gonzalez', 'jdtamayo@sena.edu.co', NULL),
(19, 'Alvaro de Jesus Echavarria Montoya', 'aechavarriam@sena.edu.co', NULL),
(20, 'Luz Adriana Orozco Arango', 'lorozcoar@sena.edu.co', NULL),
(21, 'Victor Rendon Fernandez', 'vrendon@sena.edu.co', NULL),
(22, 'Elena Castellanos', 'ecastellanosm@sena.edu.co', NULL),

-- 7. [TEST DATA] Instructor de prueba para validar filtrado por rol (P22)
-- Activar via POST /api/auth/crear-password antes de usar
(23, 'Instructor Prueba', 'instructor.prueba@sena.edu.co', NULL),

-- 8. Asistente de Coordinacion (agregado 01/07/2026 — feedback coordinadora)
(24, 'Laura Jaramillo Ospina', 'ljaramilloo@sena.edu.co', NULL),

-- 9. Instructor lider tecnico ADSO
(25, 'Luis Eladio Porras Camargo', 'lporras@sena.edu.co', NULL);

-- ============================================================
-- ROLES
-- Rol 1: Subdirector            → 2 (Dyron Ramirez)
-- Rol 2: Coordinadora Academica → 4 (Leidy Ruiz, linea transversal)
-- Rol 3: Asistente Coordinacion → 24 (Laura Jaramillo Ospina)
-- Rol 4: Instructor             → 6-9 ADSO, 13-16 transversal, 23 prueba, 25 lider tecnico
--
-- Sin rol (personal CDMC fuera de alcance inicial):
--   5  (Paul Tamayo — coordinacion medular)
--   3  (Rocio Medina — pendiente modulo juicios evaluativos instructores ADSO)
--   10, 11, 12 (instructores medulares Calzado/Cuero)
-- ============================================================
INSERT IGNORE INTO usuario_roles (usuario_id, rol_id) VALUES
(2,  1),  -- Dyron Ramirez          → Subdirector
(4,  2),  -- Leidy Ruiz             → Coordinadora Academica
(6,  4),  -- Juliana Gomez          → Instructor
(7,  4),  -- Andres Martinez        → Instructor
(8,  4),  -- Diego Gomez            → Instructor
(9,  4),  -- Ronald Quintero        → Instructor
(13, 4),  -- Sol Beatriz Castano    → Instructor
(14, 4),  -- Laura Gallego          → Instructor
(15, 4),  -- Jose Luis Cardona      → Instructor
(16, 4),  -- Sandra Velasquez       → Instructor
(23, 4),  -- Instructor Prueba      → Instructor
(24, 3),  -- Laura Jaramillo Ospina → Asistente Coordinacion
(25, 4);  -- Luis Eladio Porras Camargo → Instructor

-- ============================================================
-- INSTRUCTORES
-- Alcance inicial: ADSO (tecnica) + transversales
-- IDs 5-7 (Calzado/Cuero) excluidos hasta expansion linea medular (P26)
-- ============================================================
INSERT IGNORE INTO instructores (id, usuario_id, tipo_area) VALUES
-- ADSO/TIC (instructores 1-4)
(1, 6,  'tecnica'),
(2, 7,  'tecnica'),
(3, 8,  'tecnica'),
(4, 9,  'tecnica'),
-- Transversales (instructores 8-11)
(8,  13, 'transversal'),
(9,  14, 'transversal'),
(10, 15, 'transversal'),
(11, 16, 'transversal'),
-- [TEST DATA] Instructor de prueba (instructor 12)
(12, 23, 'tecnica'),
-- Instructor lider tecnico ADSO (instructor 13)
(13, 25, 'tecnica');

-- ============================================================
-- [TEST DATA] PROGRAMAS DE FORMACION
-- Alcance inicial: ADSO (transversal/tecnica) + Asistencia Administrativa
-- Programa Calzado (ID 2) excluido hasta expansion linea medular (P26)
-- ============================================================
INSERT IGNORE INTO programas (id, codigo, nombre, nivel, area_id, tipo_linea, tipo_area, tipo_formacion, modalidad) VALUES
(1, '228118', 'Tecnologia en Analisis y Desarrollo de Software', 'tecnologo', 1, 'transversal', 'tecnica',      'titulada', 'presencial'),
(3, 'TEST-093101', 'Tecnico en Asistencia Administrativa',            'tecnico',   2, 'transversal', 'transversal', 'titulada', 'presencial');

-- ============================================================
-- COMPETENCIAS ADSO 228118 — datos reales (fuente: Juicios Evaluativos, Ficha 2995403)
-- IDs 1-7: técnicas | IDs 8-19: transversales | ID 20: productiva
-- IDs 21-22: Asistencia Administrativa [TEST DATA] (renumeradas desde 5-6)
-- ============================================================
INSERT IGNORE INTO competencias (id, nombre, codigo, programa_id) VALUES
-- TECNICAS (7)
(1,  'Establecer requisitos de la solucion de software de acuerdo con estandares y procedimiento tecnico',                                                                              '38392', 1),
(2,  'Evaluar requisitos de la solucion de software de acuerdo con metodologias de analisis y estandares',                                                                             '38376', 1),
(3,  'Disenar la solucion de software de acuerdo con procedimientos y requisitos tecnicos',                                                                                            '38362', 1),
(4,  'Estructurar propuesta tecnica de servicio de tecnologia de la informacion segun requisitos tecnicos y normativa',                                                                 '38367', 1),
(5,  'Desarrollar la solucion de software de acuerdo con el disenio y metodologias de desarrollo',                                                                                    '38368', 1),
(6,  'Implementar la solucion de software de acuerdo con los requisitos de operacion y modelos de referencia',                                                                         '38356', 1),
(7,  'Controlar la calidad del servicio de software de acuerdo con los estandares tecnicos',                                                                                           '38369', 1),
-- TRANSVERSALES (12) — instructor transversal asigna con es_provisional=true en fichas ADSO
(8,  'Interactuar en el contexto productivo y social de acuerdo con principios eticos para la construccion de una cultura de paz',                                                     '36180', 1),
(9,  'Resultado de Aprendizaje de la Induccion',                                                                                                                                       '36182', 1),
(10, 'Utilizar herramientas informaticas de acuerdo con las necesidades de manejo de informacion',                                                                                     '37371', 1),
(11, 'Interactuar en lengua inglesa de forma oral y escrita dentro de contextos sociales y laborales',                                                                                 '37714', 1),
(12, 'Aplicar practicas de proteccion ambiental seguridad y salud en el trabajo de acuerdo con las politicas organizacionales y la normatividad vigente',                              '37799', 1),
(13, 'Generar habitos saludables de vida mediante la aplicacion de programas de actividad fisica',                                                                                     '37800', 1),
(14, 'Aplicacion de conocimientos de las ciencias naturales de acuerdo con situaciones del contexto productivo y social',                                                              '37801', 1),
(15, 'Desarrollar procesos de comunicacion eficaces y efectivos teniendo en cuenta situaciones de orden social personal y productivo',                                                  '37802', 1),
(16, 'Orientar investigacion formativa segun referentes tecnicos',                                                                                                                     '38199', 1),
(17, 'Ejercer derechos fundamentales del trabajo en el marco de la constitucion politica y los convenios internacionales',                                                             '38558', 1),
(18, 'Razonar cuantitativamente frente a situaciones susceptibles de ser abordadas de manera matematica',                                                                              '38560', 1),
(19, 'Gestionar procesos propios de la cultura emprendedora y empresarial de acuerdo con el perfil personal y los requerimientos de los contextos productivo y social',                '38561', 1),
-- PRODUCTIVA (1)
(20, 'Resultados de aprendizaje etapa practica',                                                                                                                                       '2',     1),
-- [TEST DATA] Asistencia Administrativa (renumeradas desde 5-6)
(21, 'Organizar los documentos de la unidad administrativa',  '210601001-TEST', 3),
(22, 'Atender requerimientos del cliente interno y externo',  '210601002-TEST', 3);

-- ============================================================
-- RESULTADOS DE APRENDIZAJE — ADSO 228118 (datos reales)
-- RAPs heredados automaticamente al asignar competencia (RN-15).
-- IDs 1-27: tecnicos | 28-74: transversales | 75: productivo
-- IDs 76-79: Asistencia Administrativa [TEST DATA]
-- Fuente: Reporte_de_Juicios_Evaluativos_Ficha2995403.xls
-- ============================================================
INSERT IGNORE INTO raps (id, nombre, codigo, competencia_id) VALUES
-- Competencia 1 — 38392 Establecer requisitos (4 RAPs)
(1,  'Caracterizar los procesos de la organizacion de acuerdo con el software a construir',                                                       '593346', 1),
(2,  'Recolectar informacion del software a construir de acuerdo con las necesidades del cliente',                                                 '593344', 1),
(3,  'Establecer los requisitos del software de acuerdo con la informacion recolectada',                                                           '593347', 1),
(4,  'Validar el informe de requisitos de acuerdo con las necesidades del cliente',                                                                '593345', 1),
-- Competencia 2 — 38376 Evaluar requisitos (4 RAPs)
(5,  'Planear actividades de analisis de acuerdo con la metodologia seleccionada',                                                                 '592375', 2),
(6,  'Modelar las funciones del software de acuerdo con el informe de requisitos',                                                                 '592373', 2),
(7,  'Desarrollar procesos logicos a traves de la implementacion de algoritmos',                                                                   '592376', 2),
(8,  'Verificar los modelos realizados en la fase de analisis de acuerdo con lo establecido en el informe de requisitos',                          '592374', 2),
-- Competencia 3 — 38362 Disenar solucion (4 RAPs)
(9,  'Elaborar los artefactos de disenio del software siguiendo las practicas de la metodologia seleccionada',                                     '593103', 3),
(10, 'Estructurar el modelo de datos del software de acuerdo con las especificaciones del analisis',                                               '593101', 3),
(11, 'Determinar las caracteristicas tecnicas de la interfaz grafica del software adoptando estandares',                                           '593100', 3),
(12, 'Verificar los entregables de la fase de disenio del software de acuerdo con lo establecido en el informe de analisis',                       '593102', 3),
-- Competencia 4 — 38367 Estructurar propuesta tecnica (3 RAPs)
(13, 'Definir especificaciones tecnicas del software de acuerdo con las caracteristicas del software a construir',                                 '593060', 4),
(14, 'Elaborar propuesta tecnica del software de acuerdo con las especificaciones tecnicas definidas',                                             '593062', 4),
(15, 'Validar las condiciones de la propuesta tecnica del software de acuerdo con los intereses de las partes',                                    '593061', 4),
-- Competencia 5 — 38368 Desarrollar solucion (5 RAPs)
(16, 'Planear actividades de construccion del software de acuerdo con el disenio establecido',                                                     '593106', 5),
(17, 'Construir la base de datos para el software a partir del modelo de datos',                                                                   '593107', 5),
(18, 'Crear componentes front-end del software de acuerdo con el disenio',                                                                         '593104', 5),
(19, 'Codificar el software de acuerdo con el disenio establecido',                                                                                '593108', 5),
(20, 'Realizar pruebas al software para verificar su funcionalidad',                                                                               '593105', 5),
-- Competencia 6 — 38356 Implementar solucion (4 RAPs)
(21, 'Planear actividades de implantacion del software de acuerdo con las condiciones del sistema',                                                '593111', 6),
(22, 'Desplegar el software de acuerdo con la arquitectura y las politicas establecidas',                                                          '593110', 6),
(23, 'Documentar el proceso de implantacion de software siguiendo estandares de calidad',                                                          '593109', 6),
(24, 'Implantar el software de acuerdo con los niveles de servicio establecidos con el cliente',                                                   '593112', 6),
-- Competencia 7 — 38369 Controlar calidad (3 RAPs)
(25, 'Incorporar actividades de aseguramiento de la calidad del software de acuerdo con estandares de la industria',                               '593146', 7),
(26, 'Verificar la calidad del software de acuerdo con las practicas asociadas en los procesos de desarrollo',                                     '593144', 7),
(27, 'Realizar actividades de mejora de la calidad del software a partir de los resultados de la verificacion',                                    '593145', 7),
-- Competencia 8 — 36180 Etica y cultura de paz (4 RAPs)
(28, 'Promover mi dignidad y la del otro a partir de los principios y valores eticos como aporte en la instauracion de una cultura de paz',        '593149', 8),
(29, 'Establecer relaciones de crecimiento personal y comunitario a partir del bien comun como aporte para el desarrollo social',                  '593147', 8),
(30, 'Promover el uso racional de los recursos naturales a partir de criterios de sostenibilidad y sustentabilidad etica y normativa vigente',     '593148', 8),
(31, 'Contribuir con el fortalecimiento de la cultura de paz a partir de la dignidad humana y las estrategias para la transformacion de conflictos','593150', 8),
-- Competencia 9 — 36182 Induccion (1 RAP)
(32, 'Identificar la dinamica organizacional del SENA y el rol de la formacion profesional integral de acuerdo con su proyecto de vida',           '593343', 9),
-- Competencia 10 — 37371 Herramientas informaticas (4 RAPs)
(33, 'Alistar herramientas TIC de acuerdo con las necesidades de procesamiento de informacion y comunicacion',                                     '593154', 10),
(34, 'Aplicar funcionalidades de herramientas y servicios TIC de acuerdo con manuales de uso y buenas practicas',                                  '593151', 10),
(35, 'Evaluar los resultados de acuerdo con los requerimientos',                                                                                   '593153', 10),
(36, 'Optimizar los resultados de acuerdo con la verificacion',                                                                                    '593152', 10),
-- Competencia 11 — 37714 Ingles (6 RAPs)
(37, 'Comprender informacion sobre situaciones cotidianas y laborales a traves de interacciones sociales de forma oral y escrita',                 '593117', 11),
(38, 'Intercambiar opiniones sobre situaciones cotidianas y laborales en contextos sociales orales y escritos',                                    '593115', 11),
(39, 'Discutir sobre posibles soluciones a problemas dentro de un rango variado de contextos sociales y laborales',                                '593118', 11),
(40, 'Implementar acciones de mejora relacionadas con el uso de expresiones y estructuras segun los resultados de aprendizaje del programa',       '593114', 11),
(41, 'Presentar un proceso para la realizacion de una actividad en su quehacer laboral de acuerdo con los procedimientos del programa',            '593116', 11),
(42, 'Explicar las funciones de su ocupacion laboral usando expresiones de acuerdo al nivel requerido por el programa de formacion',               '593113', 11),
-- Competencia 12 — 37799 Proteccion ambiental y SST (4 RAPs)
(43, 'Analizar las estrategias para la prevencion y control de los impactos ambientales y de los accidentes y enfermedades laborales (ATEL)',      '593156', 12),
(44, 'Implementar estrategias para el control de los impactos ambientales y enfermedades de acuerdo con los planes y programas establecidos',      '593158', 12),
(45, 'Realizar seguimiento y acompanamiento al desarrollo de los planes y programas ambientales y SST',                                            '593157', 12),
(46, 'Proponer acciones de mejora para el manejo ambiental y el control de la SST de acuerdo con estrategias de trabajo colaborativo',             '593155', 12),
-- Competencia 13 — 37800 Habitos saludables (4 RAPs)
(47, 'Desarrollar habilidades psicomotrices en el contexto productivo y social',                                                                   '593120', 13),
(48, 'Practicar habitos saludables mediante la aplicacion de fundamentos de nutricion e higiene',                                                  '593119', 13),
(49, 'Ejecutar actividades de acondicionamiento fisico orientadas hacia el mejoramiento de la condicion fisica',                                   '593121', 13),
(50, 'Implementar un plan de ergonomia y pausas activas segun las caracteristicas de la funcion productiva',                                       '593122', 13),
-- Competencia 14 — 37801 Ciencias naturales (4 RAPs)
(51, 'Identificar los principios y leyes de la fisica en la solucion de problemas de acuerdo al contexto productivo',                             '593162', 14),
(52, 'Solucionar problemas asociados con el sector productivo con base en los principios y leyes de la fisica',                                    '593159', 14),
(53, 'Verificar las transformaciones fisicas de la materia utilizando herramientas tecnologicas',                                                  '593161', 14),
(54, 'Proponer acciones de mejora en los procesos productivos de acuerdo con los principios y leyes de la fisica',                                 '593160', 14),
-- Competencia 15 — 37802 Comunicacion (4 RAPs)
(55, 'Analizar los componentes de la comunicacion segun sus caracteristicas intencionalidad y contexto',                                           '593225', 15),
(56, 'Argumentar en forma oral y escrita atendiendo las exigencias de las diversas situaciones comunicativas',                                     '593227', 15),
(57, 'Relacionar los procesos comunicativos teniendo en cuenta criterios de logica y racionalidad',                                                '593224', 15),
(58, 'Establecer procesos de enriquecimiento lexical y acciones de mejoramiento en el desarrollo de procesos comunicativos',                       '593226', 15),
-- Competencia 16 — 38199 Investigacion formativa (4 RAPs)
(59, 'Analizar el contexto productivo segun sus caracteristicas y necesidades',                                                                    '593236', 16),
(60, 'Estructurar el proyecto de acuerdo a criterios de la investigacion',                                                                         '593238', 16),
(61, 'Argumentar aspectos teoricos del proyecto segun referentes nacionales e internacionales',                                                    '593237', 16),
(62, 'Proponer soluciones a las necesidades del contexto segun resultados de la investigacion',                                                    '593235', 16),
-- Competencia 17 — 38558 Derechos fundamentales del trabajo (4 RAPs)
(63, 'Reconocer el trabajo como factor de movilidad social y transformacion vital con referencia a la fenomenologia y los derechos fundamentales', '593243', 17),
(64, 'Valorar la importancia de la ciudadania laboral con base en el estudio de los derechos humanos y fundamentales en el trabajo',               '593245', 17),
(65, 'Practicar los derechos fundamentales en el trabajo de acuerdo con la Constitucion Politica y los Convenios Internacionales',                 '593244', 17),
(66, 'Participar en acciones solidarias teniendo en cuenta el ejercicio de los derechos humanos de los pueblos y de la naturaleza',                '593246', 17),
-- Competencia 18 — 38560 Razonamiento cuantitativo (4 RAPs)
(67, 'Identificar modelos matematicos de acuerdo con los requerimientos del problema planteado en contextos sociales y productivo',                '593256', 18),
(68, 'Plantear problemas matematicos a partir de situaciones generadas en el contexto social y productivo',                                        '593258', 18),
(69, 'Resolver problemas matematicos a partir de situaciones generadas en el contexto social y productivo',                                        '593255', 18),
(70, 'Proponer acciones de mejora frente a los resultados de los procedimientos matematicos de acuerdo con el problema planteado',                 '593257', 18),
-- Competencia 19 — 38561 Emprendimiento (4 RAPs)
(71, 'Integrar elementos de la cultura emprendedora teniendo en cuenta el perfil personal y el contexto de desarrollo social',                     '593342', 19),
(72, 'Caracterizar la idea de negocio teniendo en cuenta las oportunidades y necesidades del sector productivo y social',                          '593259', 19),
(73, 'Estructurar el plan de negocio de acuerdo con las caracteristicas empresariales y tendencias de mercado',                                    '593340', 19),
(74, 'Valorar la propuesta de negocio conforme con su estructura y necesidades del sector productivo y social',                                    '593341', 19),
-- Competencia 20 — Etapa productiva (1 RAP)
(75, 'Aplicar en la resolucion de problemas reales los conocimientos habilidades y destrezas del programa asumiendo metodologias de autogestion',  '590803', 20),
-- [TEST DATA] Asistencia Administrativa (renumerados desde 9-12, vinculados a comp 21-22)
(76, 'Clasificar y archivar documentos segun el sistema de gestion', 'RAP-01-001A-TEST', 21),
(77, 'Aplicar las normas de gestion documental vigentes',            'RAP-02-001A-TEST', 21),
(78, 'Recibir y canalizar requerimientos del cliente',               'RAP-01-002A-TEST', 22),
(79, 'Hacer seguimiento a la solucion de los requerimientos',        'RAP-02-002A-TEST', 22);

-- ============================================================
-- [TEST DATA] COMPETENCIAS HABILITADAS POR INSTRUCTOR (RN-13)
-- Sin estas entradas, POST /api/asignaciones falla con 422.
-- Instructores medulares (IDs 5-7) excluidos del alcance inicial.
-- ============================================================
INSERT IGNORE INTO instructor_competencias_habilitadas (instructor_id, competencia_id) VALUES
-- Tecnicos ADSO (instructores 1-4) → 7 competencias tecnicas (1-7)
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),
(2,1),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),
(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),
(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),
-- Transversales (instructores 8-11) → 12 competencias transversales (8-19)
(8,8),(8,9),(8,10),(8,11),(8,12),(8,13),(8,14),(8,15),(8,16),(8,17),(8,18),(8,19),
(9,8),(9,9),(9,10),(9,11),(9,12),(9,13),(9,14),(9,15),(9,16),(9,17),(9,18),(9,19),
(10,8),(10,9),(10,10),(10,11),(10,12),(10,13),(10,14),(10,15),(10,16),(10,17),(10,18),(10,19),
(11,8),(11,9),(11,10),(11,11),(11,12),(11,13),(11,14),(11,15),(11,16),(11,17),(11,18),(11,19),
-- [TEST DATA] Instructor prueba (instructor 12) → tecnicas ADSO
(12,1),(12,2),(12,3),(12,4),(12,5),(12,6),(12,7),
-- Instructor lider tecnico (instructor 13) → tecnicas ADSO + productiva
(13,1),(13,2),(13,3),(13,4),(13,5),(13,6),(13,7),(13,20);

-- ============================================================
-- [TEST DATA] FICHAS DE FORMACION
-- Ficha 2 (Calzado) excluida del alcance inicial.
-- ============================================================
-- (omitido: bloque transaccional de la tabla fichas)  -- Asist. Administrativa, manana, Aula 201

-- ============================================================
-- LIDER DE PROGRAMA
-- Juliana Gomez (instructor 1) → ADSO (programa 1)
-- Informativo — no genera rol de sistema (lider_programa ya no es rol).
-- ============================================================
INSERT IGNORE INTO lider_programa (instructor_id, programa_id) VALUES
(1, 1);

-- ============================================================
-- FICHAS PRODUCTIVAS (datos reales — aplican cuando se importen fichas reales)
-- Fichas 3065123 y 3065121 salen a etapa practica el 14/07/2026.
-- Requiere schema v5.3+ (columna fecha_inicio_productiva en fichas).
-- ============================================================
UPDATE fichas SET fecha_inicio_productiva = '2026-07-14'
WHERE numero_ficha IN ('3065123', '3065121');


-- ============================================================
-- LIMPIEZA — dejar solo ADSO real (19/08/2026, simulacro camino feliz)
-- (1) Quita instructor de prueba (usuario 23 / instructor 12).
-- (2) Quita programa no-ADSO "Asistencia Administrativa" (programa 3,
--     competencias 21-22, RAPs 76-79, ficha 3).
-- (3) Quita instructores placeholder sin plan de agosto (1-4 y 8-11) y sus
--     usuarios (6-9, 13-16).
-- (4) Carlos Alvarez (usuario/instructor 114): LIDER del programa ADSO.
--     No dicta horas (0 carga), pero es el referente del programa.
-- Instructores finales: 14 que dictan (13=Luis + 101-113) + Carlos (lider).
-- ============================================================
-- (4) Lider del programa ADSO = Carlos Alvarez (sin horas, referente)
INSERT IGNORE INTO usuarios (id, nombre, email, password) VALUES
  (114, 'Carlos Alvarez', 'calvarez@sena.edu.co', NULL);
INSERT IGNORE INTO usuario_roles (usuario_id, rol_id) VALUES (114, 4);
INSERT IGNORE INTO instructores (id, usuario_id, tipo_area) VALUES (114, 114, 'tecnica');
INSERT IGNORE INTO instructor_competencias_habilitadas (instructor_id, competencia_id) VALUES
  (114,1),(114,2),(114,3),(114,4),(114,5),(114,6),(114,7);
DELETE FROM lider_programa WHERE programa_id = 1;
INSERT IGNORE INTO lider_programa (instructor_id, programa_id) VALUES (114, 1);
-- (1)+(3) instructores de prueba y placeholder
DELETE FROM instructor_competencias_habilitadas WHERE instructor_id IN (1,2,3,4,8,9,10,11,12) OR competencia_id IN (21,22);
DELETE FROM instructores WHERE id IN (1,2,3,4,8,9,10,11,12);
DELETE FROM usuario_roles WHERE usuario_id IN (6,7,8,9,13,14,15,16,23);
DELETE FROM usuarios WHERE id IN (6,7,8,9,13,14,15,16,23);
-- (2) programa no-ADSO + dependencias
DELETE FROM fichas WHERE id = 3;
DELETE FROM raps WHERE competencia_id IN (21,22);
DELETE FROM competencias WHERE id IN (21,22);
DELETE FROM programas WHERE id = 3;

-- ============================================================
-- SEED DEMO — Programacion real ADSO Agosto 2026 (simulacro directivas)
-- Generado 19/08/2026 (rev3). IDs 100+; Luis reutiliza instructor 13 / usuario 25.
-- es_provisional: solo Walver->ficha 3156009 (trabajo conjunto, titular Wilmar).
-- El resto es asignacion NORMAL (transversales/bilinguismo incluidos).
-- Correos MOCK. Requiere seed base + database.sql actual (sin trigger RN-05).
-- ============================================================

INSERT IGNORE INTO ambientes (id, nombre, tipo, capacidad, area_id, sede_id, activo) VALUES
  (100, 'Aula Ambiental La Estrella', 'aula', 30, NULL, NULL, TRUE),
  -- Salones fisicos referenciados en la planeacion del lider (ADSO). Nombres
  -- deben coincidir EXACTO con lo que emite el normalizador ("Ambiente NNN"),
  -- porque el importador resuelve el ambiente por nombre.
  (200, 'Ambiente 200', 'aula', 30, NULL, NULL, TRUE),
  (202, 'Ambiente 202', 'aula', 30, NULL, NULL, TRUE),
  (204, 'Ambiente 204', 'aula', 30, NULL, NULL, TRUE),
  (206, 'Ambiente 206', 'aula', 30, NULL, NULL, TRUE);

INSERT IGNORE INTO usuarios (id, nombre, email, password) VALUES
  (101, 'Yuri Vinasco', 'yvinasco@sena.edu.co', NULL),
  (102, 'Jesus Carvajal', 'jcarvajal@sena.edu.co', NULL),
  (103, 'Martha Isabel Medina', 'mmedina@sena.edu.co', NULL),
  (104, 'Jonny Barco', 'jbarco@sena.edu.co', NULL),
  (105, 'Oscar Naranjo', 'onaranjo@sena.edu.co', NULL),
  (106, 'Anderson Silva', 'asilva@sena.edu.co', NULL),
  (107, 'Lina Serna', 'lserna@sena.edu.co', NULL),
  (108, 'Jaime Alexis Garcia', 'jgarcia@sena.edu.co', NULL),
  (109, 'Steffany Rivas', 'srivas@sena.edu.co', NULL),
  (110, 'Walver Antonio Rodriguez Carmona', 'wrodriguez@sena.edu.co', NULL),
  (111, 'Darwin Yusef Gonzalez Triana', 'dgonzalez@sena.edu.co', NULL),
  (112, 'Edwin Bustamante', 'ebustamante@sena.edu.co', NULL),
  (113, 'Wilmar Alexander Zapata', 'wzapata@sena.edu.co', NULL);

INSERT IGNORE INTO usuario_roles (usuario_id, rol_id) VALUES
  (101, 4),
  (102, 4),
  (103, 4),
  (104, 4),
  (105, 4),
  (106, 4),
  (107, 4),
  (108, 4),
  (109, 4),
  (110, 4),
  (111, 4),
  (112, 4),
  (113, 4);

INSERT IGNORE INTO instructores (id, usuario_id, tipo_area) VALUES
  (101, 101, 'transversal'),
  (102, 102, 'transversal'),
  (103, 103, 'transversal'),
  (104, 104, 'transversal'),
  (105, 105, 'transversal'),
  (106, 106, 'transversal'),
  (107, 107, 'transversal'),
  (108, 108, 'transversal'),
  (109, 109, 'transversal'),
  (110, 110, 'tecnica'),
  (111, 111, 'tecnica'),
  (112, 112, 'tecnica'),
  (113, 113, 'tecnica');

INSERT IGNORE INTO instructor_competencias_habilitadas (instructor_id, competencia_id) VALUES
  (101, 11),
  (102, 11),
  (104, 11),
  (105, 18),
  (106, 15),
  (107, 15),
  (108, 16),
  (109, 12),
  (110, 3),
  (110, 5),
  (111, 5),
  (112, 2),
  (113, 5);

-- (omitido: bloque transaccional de la tabla fichas)

-- (omitido: bloque transaccional de la tabla asignacion)

-- (omitido: bloque transaccional de la tabla asignacion_competencia)

-- (omitido: bloque transaccional de la tabla asignacion_rap)

-- (omitido: bloque transaccional de la tabla horarios)

-- ============================================================
-- MARTHA ISABEL MEDINA — reconstruccion desde el Excel (25/08/2026)
-- Instructora de Bilinguismo (transversal) en ficha 3519093 (id 103). Salia con
-- 0 horas porque su asignacion no se habia sembrado (su fila venia mal
-- etiquetada en la fuente). La competencia de ingles YA existe en el catalogo
-- (id 11, codigo 37714), asi que se reutiliza; solo se agrega su RAP especifico.
-- Provisional por ser transversal en ficha ADSO. Fuente: hoja Bilinguismo.
-- ============================================================
INSERT IGNORE INTO raps (id, nombre, codigo, competencia_id) VALUES
  (80, 'Describir a nivel basico, de forma oral y escrita en ingles personas, situaciones y lugares de acuerdo con su contexto', 'RAP-37714-01', 11);

INSERT IGNORE INTO instructor_competencias_habilitadas (instructor_id, competencia_id) VALUES
  (103, 11);

-- (omitido: bloque transaccional de la tabla asignacion)

-- (omitido: bloque transaccional de la tabla asignacion_competencia)

-- (omitido: bloque transaccional de la tabla horarios)

-- ============================================================
-- ALERTA sembrada (25/08/2026): el seed inserta directo (salta los services),
-- asi que las condiciones no generan alertas solas. Se siembra el hallazgo real
-- de RN-06: en el grupo 3156009 (ficha 106) el RAP 19 ("Codificar el software")
-- quedo a cargo de DOS instructores, Darwin (111) y Wilmar (113). Esto viola la
-- regla (al evaluar el RAP no pueden existir dos juicios distintos para el mismo
-- grupo) y debe CORREGIRSE reasignando el RAP a un solo instructor. Queda visible
-- para coordinacion y para el lider del programa hasta que se corrija/atienda.
-- ============================================================
-- (omitido: bloque transaccional de la tabla alertas)

-- Notificaciones (campanita) del hallazgo RN-06 sembrado, para que enciendan el
-- badge del header en el demo: lider del programa (Carlos, usuario 114),
-- coordinadora (Leidy, usuario 4) y subdirector (Dyron, usuario 2).
-- (omitido: bloque transaccional de la tabla notificaciones)
