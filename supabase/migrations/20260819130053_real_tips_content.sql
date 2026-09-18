-- Reemplaza el contenido borrador de Tips por el real y aprobado del paquete
-- de diseño (insights.js): 5 categorías (antes eran otras 5, sin relación) y
-- 18 tips con "hook" corto, filtrados por franja de edad.

alter table public.guide_tips add column hook text;
alter table public.guide_tips add column ages text not null default '*';
alter table public.guide_categories add column icon text;

delete from public.guide_tips;
delete from public.guide_categories;

insert into public.guide_categories (id, label, icon, position) values
  ('noche', 'Noche', '☾', 1),
  ('siestas', 'Siestas', '◐', 2),
  ('rutina', 'Rutina', '◇', 3),
  ('tomas', 'Tomas', '◍', 4),
  ('regresiones', 'Etapas', '◔', 5);

insert into public.guide_tips (id, category_id, title, hook, body, how, ages, position) values
  ('t01', 'noche', 'Antes de cambiar el método, cambiá el reloj', 'Casi siempre el problema no es cómo se duerme.',
   'Cuando la noche se rompe, el instinto es cambiar la forma de dormirla. Casi nunca es ahí. Primero se revisa el ambiente del cuarto, después las ventanas de vigilia, después la rutina y por último la alimentación del día. Recién cuando esas cuatro cosas están ordenadas tiene sentido tocar la asociación de sueño, porque si no vas a estar peleando contra un bebé sobrecansado.',
   array['Cuarto oscuro, fresco y con ruido blanco constante', 'Ventanas dentro del rango de su edad, sin estirarlas', 'Misma rutina, mismo orden, todas las noches'], '*', 1),
  ('t02', 'noche', 'El llanto no enseña a dormir', 'Es la reacción al cambio, no la lección.',
   'Nadie aprende a dormir llorando. El llanto aparece porque le estás cambiando una costumbre muy arraigada y es la única forma que tiene de contarte que está incómoda. No es una señal de que lo estés haciendo mal, ni algo que haya que apagar rápido. Tu trabajo no es que deje de llorar: es estar ahí, entera y en calma, mientras se acomoda a la forma nueva.',
   array['Quedate presente y con voz tranquila', 'No cambies de estrategia a mitad del llanto', 'Turnate con tu pareja si te estás desregulando'], '*', 2),
  ('t03', 'noche', 'La inconsistencia es lo que alarga el llanto', 'Responder distinto cada noche reinicia el proceso.',
   'Si una noche la cargás, otra la dejás llorar y otra la llevás a tu cama, no puede anticipar qué va a pasar y cada noche vuelve a empezar de cero. Responder siempre igual le da algo predecible a lo que agarrarse, y eso —no el método en sí— es lo que hace que el llanto baje noche a noche.',
   array['Acordá con tu pareja y la niñera la misma respuesta', 'Sostenela mínimo 3 noches antes de juzgarla', 'Si hay que ajustar, ajustá de día, no a las 3 am'], '*', 3),
  ('t04', 'rutina', 'Acostala en 2, no en 4', 'Despierta pero tranquila, ese es el punto exacto.',
   'Imaginá una escala del 1 al 5, donde 1 es completamente activa y 5 es dormida. El punto donde queremos que llegue a la cuna es el 2, como mucho el 3. Si llega en 4 o 5 no está aprendiendo a dormirse, se está durmiendo en tus brazos y despertando en un lugar distinto. No hace falta arrullarla; sí hace falta un momento de calma antes de acostarla.',
   array['Bajá luces y voz 20 min antes', 'Un rato de conexión: cuento, canción, abrazo', 'A la cama con los ojos todavía abiertos'], '*', 4),
  ('t05', 'rutina', 'Quedarte en el mismo escalón estanca todo', 'Más de 4 o 5 días igual y el proceso se frena.',
   'Cada posición del acompañamiento es un escalón temporal, no un lugar donde quedarse. Si te quedás más de cuatro o cinco días en el mismo punto, deja de ser un proceso y pasa a ser la nueva costumbre. La única excepción es que esté enferma: ahí se pausa y se retoma después.',
   array['Avanzá cada 3 días si la noche lo permite', 'Si un escalón cuesta, ajustá el ritmo pero no vuelvas atrás', 'Anotá en qué noche vas para no perder el hilo'], '*', 5),
  ('t06', 'noche', 'La latencia te dice si la hora está bien', 'Cuánto tarda en dormirse es tu mejor termómetro.',
   'Si tarda 30 minutos o más en dormirse estando tranquila, la estás acostando demasiado temprano: atrasá la noche 15 minutos. Si se duerme en menos de 5 minutos, llega sobrecansada: adelantala 15. El objetivo es que se duerma en unos 10 a 20 minutos, sin drama.',
   array['Anotá cuándo empezaste y cuándo se durmió', 'Ajustá de a 15 min, nunca de golpe', 'Sostené el cambio 3 noches antes de volver a mover'], '*', 6),
  ('t07', 'noche', 'A las 5:40 todavía es de noche', 'Un despertar temprano no es el inicio del día.',
   'El día empieza entre las 5:30 y las 7:00, cuando ya hay luz. Si despierta antes de eso, se trata exactamente igual que cualquier despertar nocturno: no se prende la luz, no se saca del cuarto, no se le da de comer todavía. Detrás de un despertar muy temprano casi siempre hay sobrecansancio, una siesta demasiado larga, o una noche que empezó demasiado temprano.',
   array['Mantené el cuarto oscuro hasta la hora real', 'Revisá que la siesta no se haya estirado', 'Probá atrasar la noche 15 min unos días'], '*', 7),
  ('t08', 'tomas', 'La pregunta no es si comió, es si le tocaba', 'Ahí está la diferencia entre hambre y costumbre.',
   'Con el pediatra se define cuántas tomas nocturnas se mantienen según peso, crecimiento, edad y sólidos. A partir de ahí, cada despertar tiene dos caminos: si le tocaba esa toma, se la das tranquila y vuelve a la cama; si no le tocaba, la acompañás hasta que se duerma o hasta la hora en que sí le corresponde comer. Sin esa distinción, todas las tomas parecen hambre.',
   array['Definí con el pediatra cuántas tomas nocturnas quedan', 'Marcá cada toma como «le tocaba» o no', 'Si no le tocaba, acompañá sin ofrecer'], '*', 8),
  ('t09', 'tomas', 'Que se duerma comiendo no arruina la noche', 'Depende de si es la única forma que tiene.',
   'Si se quedó dormida durante una toma que le correspondía, no pasa absolutamente nada y no hay que despertarla para acostarla. El problema aparece cuando el pecho o el biberón se vuelven la única llave para volver a dormirse, porque entonces te va a necesitar en cada ciclo de sueño de la noche.',
   array['No la despiertes si se durmió en una toma que le tocaba', 'Ofrecé la toma al principio de la rutina, no al final', 'Si es la única forma, trabajalo de día primero'], '*', 9),
  ('t10', 'siestas', 'Siesta corta: no la saques enseguida', 'Dale la chance de encadenar el segundo ciclo.',
   'Si se despierta antes de los 45 minutos (o de los 90 si ya hace una sola siesta), dejala en la cuna hasta completar una hora desde que se durmió, acompañándola si llora. Muchas veces vuelve a dormirse y encadena. Si al cumplirse la hora sigue despierta, ahí sí se termina la siesta y arrancás la ventana.',
   array['Esperá hasta los 60 min desde que se durmió', 'Acompañá desde donde estés en el proceso', 'Si no se duerme, cerrá y ajustá la próxima ventana'], '*', 10),
  ('t11', 'siestas', 'Si no se durmió en una hora, cerrá', 'Insistir más allá de eso juega en contra.',
   'Después de una hora intentando sin que se duerma, la siesta se da por terminada. Sacala del cuarto con naturalidad, sin frustración y sin que sea un premio, y volvé a intentar unos 45 a 60 minutos más tarde. Estirar el intento solo convierte la cuna en un lugar de pelea.',
   array['Una hora de intento como máximo', 'Sacala sin fiesta y sin reproche', 'Reintentá en 45–60 min'], '*', 11),
  ('t12', 'siestas', 'A esta edad manda la ventana, no el reloj', 'Las siestas todavía no tienen horario fijo.',
   'Querer clavar horarios exactos a esta edad genera frustración: las siestas se van corriendo según cómo durmió la anterior. Lo que sí importa es que ninguna ventana se pase de lo esperado para su edad y que el total de horas en 24 h esté en rango. El horario fijo llega solo, más adelante.',
   array['Contá desde que despertó, no desde una hora fija', 'Mirá el total de 24 h como brújula', 'Anticipate a las señales de sueño, no las esperes'], 'nb,3-6,6-9,9-12', 12),
  ('t13', 'siestas', 'La siesta no debería pasar de las 15:30', 'Con una sola siesta, la tarde define la noche.',
   'Con una única siesta el día se arma distinto: arranca entre las 12:30 y las 13:00, y no conviene que se extienda más allá de las 15:30. La hora de dormir se calcula entre 4 y 4 horas y media después de que despierta de la siesta. Si duerme hasta tarde, la noche se corre y aparecen los despertares.',
   array['Despertala si sigue dormida a las 15:30', 'Contá 4–4,5 h desde que despertó para la noche', 'Nada de siesta en el carro después de esa hora'], '12-18,18-36,36+', 13),
  ('t14', 'siestas', 'Dejar de dormir la siesta suele ser una huelga', 'Y las huelgas pasan solas en un par de semanas.',
   'Si de un día para otro deja de dormir la siesta y todavía no está cerca de los tres años, casi seguro es una huelga y no el final real de la siesta. Revisá que los horarios no se hayan corrido y seguí ofreciéndola igual: el momento de descanso se sostiene aunque no duerma, y en una o dos semanas suele volver.',
   array['Sostené el horario y el ritual aunque no duerma', 'Que sea un rato de calma en su cuarto igual', 'Si no duerme, adelantá la noche 30–45 min'], '18-36,36+', 14),
  ('t15', 'regresiones', 'Lo de ahora tiene nombre: 18 a 24 meses', 'Más berrinche, más compañía, más despertares.',
   'En esta etapa pide mucha más compañía para dormirse, se resiste abiertamente a la siesta, aparecen despertares en los que solo quiere presencia, berrinches y ansiedad de separación. No es un retroceso de lo que lograron: es una etapa. Se sostiene con límites claros dichos con cariño, empatía cuando explota, y apoyos visuales que le anticipen lo que viene.',
   array['Límite firme, tono suave, siempre el mismo', 'Nombrale lo que siente antes de corregir', 'Usá un cartel o secuencia de dibujos con la rutina'], '18-36', 15),
  ('t16', 'regresiones', 'No todo lo que se rompe es una regresión', 'Si siempre durmió mal, esto es otra cosa.',
   'Una regresión es un cambio en un sueño que antes funcionaba, y dura semanas, no meses. Si nunca durmió bien, no hay nada que regresar: hay un hábito para construir. Si ahora tarda más en dormirse, mirá primero los horarios. Y si dejó una siesta, eso es una transición normal del desarrollo, no una regresión.',
   array['Si pasa del mes, dejá de esperar y actuá', 'Revisá horarios antes de asumir regresión', 'Anotá cuándo empezó para medirlo'], '*', 16),
  ('t17', 'regresiones', 'Una gripe de tres días deja un hábito de tres meses', 'Lo que empieza por enfermedad se queda.',
   'Durante la enfermedad hacés lo que haga falta, y está perfecto. El problema es después: muchos despertares que arrancaron con una gripe se quedan como costumbre porque nadie volvió al plan anterior. En cuanto mejore, retomá la rutina y los horarios de siempre, y evitá sacarla de su espacio de sueño mientras dure.',
   array['Cuidala como necesite mientras esté enferma', 'Volvé al plan al segundo día de mejora', 'Si podés, que duerma en su cuarto igual'], '*', 17),
  ('t18', 'regresiones', 'Pesadilla y terror nocturno se manejan al revés', 'Una pide consuelo, el otro pide que no la toques.',
   'La pesadilla ocurre en la segunda mitad de la noche, se despierta de verdad y la recuerda: ahí sí se la abraza, se la calma y al día siguiente se habla del tema. El terror nocturno pasa en las primeras horas, puede gritar o moverse con los ojos abiertos pero no está despierta y no lo va a recordar: no conviene tocarla ni despertarla, solo cuidar que no se lastime.',
   array['Pesadilla: consuelo en el momento, charla al día siguiente', 'Terror: quedate cerca, sin tocarla ni despertarla', 'Los terrores bajan cuando baja el sobrecansancio'], '36+', 18),
  ('t19', 'rutina', 'Con mellizas, la silla va en el medio', 'Una sola posición para poder atender a las dos.',
   'Con dos bebés en el mismo cuarto no funciona atender a una y después a la otra: te colocás entre las dos cunas o camas, de modo que estés disponible para ambas a la vez, y vas alejando esa posición hacia la puerta cada tres noches. El ruido blanco constante hace mucho: amortigua el llanto de una para que no despierte a la otra.',
   array['Silla equidistante, no al lado de una sola', 'Alejá la silla cada 3 noches, no antes', 'Ruido blanco toda la noche, no solo al principio'], '*', 19),
  ('t20', 'rutina', 'Si se baja de la cama, sé lo más aburrido posible', 'Cualquier reacción grande es un premio.',
   'Nada de explicaciones largas ni negociaciones: le recordás en pocas palabras que tiene que estar en su cama para que puedas acompañarla, y la volvés a acostar. Si insiste, salís del cuarto unos segundos y volvés. Y si aparece en tu cuarto en la madrugada, la acompañás de vuelta en silencio total, sin conversación, las veces que haga falta.',
   array['Una sola frase, siempre la misma', 'Cero contacto visual prolongado de madrugada', 'Volvé a acostarla tantas veces como haga falta'], '12-18,18-36,36+', 20);
