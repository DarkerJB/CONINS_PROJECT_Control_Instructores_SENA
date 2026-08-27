// Lunes de la semana en curso en formato YYYY-MM-DD.
// IMPORTANTE: se calcula todo con componentes LOCALES y se formatea a mano.
// Antes se usaba toISOString() (UTC): en zonas detras de UTC (p. ej. Colombia
// UTC-5) por la tarde/noche el resultado saltaba al dia siguiente en UTC y
// devolvia una fecha que no era lunes (ej. 2026-08-25), sin coincidir con la
// columna horarios.semana -> carga horaria en 0 para todos.
export function getLunesSemanaActual(): string {
  const now = new Date();
  const day = now.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  const lunes = new Date(now.getFullYear(), now.getMonth(), now.getDate() + diff);
  const y = lunes.getFullYear();
  const m = String(lunes.getMonth() + 1).padStart(2, '0');
  const d = String(lunes.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}
