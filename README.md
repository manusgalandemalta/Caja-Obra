# Caja de obra — Dario y Tomás

Una app web para cargar gastos, ingresos y compensaciones de las obras. Los datos se guardan en Supabase, así que los dos socios ven lo mismo en vivo desde el celular.

```
caja-obra/
├── index.html           ← la app
├── config.js            ← acá van la URL y la clave de Supabase
└── supabase/schema.sql  ← crea las tablas y la seguridad (se corre una vez)
```

---

## Paso 1 · Crear la base en Supabase (5 min)

1. Entrá a <https://supabase.com/dashboard> → **New project**. Ponele de nombre `caja-obra` y elegí la región **São Paulo**, que es la más cercana. Guardá la contraseña de la base en algún lado.
2. Cuando termine de crearse, andá a **SQL Editor → New query**.
3. Abrí `supabase/schema.sql`. En la **sección 6**, cambiá los dos mails de ejemplo por los mails reales de Dario y de Tomás. Van en minúscula.
4. Pegá todo el archivo en el editor y tocá **Run**. Tiene que decir *Success*.

## Paso 2 · Crear los dos usuarios

1. **Authentication → Users → Add user → Create new user**.
2. Poné el mail de Dario y una contraseña, y tildá **Auto Confirm User**.
3. Repetí lo mismo para Tomás.
4. En **Authentication → Sign In / Providers**, apagá **Allow new users to sign up**. Así nadie más puede crearse una cuenta.

> Ojo: el mail que pongas en el paso 2 tiene que ser exactamente el mismo que pusiste en `schema.sql`. Si no coinciden, la app dice "Este mail no está habilitado como socio".

## Paso 3 · Conectar la app

1. En Supabase, entrá a **Project Settings → API** (o **API Keys**) y copiá dos cosas:
   - la **Project URL**, que tiene la forma `https://xxxx.supabase.co`;
   - la clave **anon public**, o la **publishable**, que empieza con `sb_publishable_`.
2. Abrí `config.js` y pegalas en las dos líneas que dicen `TU-PROYECTO` y `PEGÁ-ACÁ`.

> Esas dos claves son públicas por diseño: se pueden subir a GitHub sin problema. Lo que protege los datos son las reglas de seguridad del `schema.sql`, que solo dejan entrar a los mails de los dos socios. **Nunca** pongas la clave `service_role` ni la `secret`.

## Paso 4 · Publicarla

### Opción A · GitHub Pages (con GitHub Desktop)

1. En GitHub Desktop: **File → New repository**. Ponele de nombre `caja-obra` y elegí la carpeta donde lo querés guardar.
2. Copiá dentro de esa carpeta los archivos `index.html` y `config.js`, y la carpeta `supabase/`.
3. Escribí "Primera versión" en el resumen y tocá **Commit to main** y después **Publish repository**. Destildá *Keep this code private* si tu plan no incluye Pages privado.
4. En github.com, entrá al repo → **Settings → Pages**. En *Source* elegí **Deploy from a branch**, después **main / (root)**, y tocá **Save**.
5. En 1 o 2 minutos queda andando en `https://TU-USUARIO.github.io/caja-obra/`.

### Opción B · Netlify

1. Entrá a <https://app.netlify.com/drop> y arrastrá la carpeta `caja-obra` entera. Listo, te da un link.
2. Si después querés que se actualice solo cada vez que cambies algo en GitHub: **Add new site → Import from GitHub** y elegí el repo.

## Paso 5 · Usarla en el celular

- Abrí el link, entrá con tu mail y tu contraseña, y agregala a la pantalla de inicio:
  - **iPhone:** Safari → Compartir → *Agregar a inicio*.
  - **Android:** Chrome → menú ⋮ → *Agregar a la pantalla principal*.
- La sesión queda abierta, así que no hace falta volver a entrar cada vez.

## Pasar los datos que ya cargaron en el lienzo de Claude

1. En el lienzo, tocá **Exportar JSON**.
2. En la app nueva, tocá **Importar JSON** y elegí ese archivo. Los movimientos se **agregan** a lo que ya haya, y los clientes con el mismo nombre se reutilizan.

> El lienzo arranca con datos de ejemplo. Si no querés pasarlos, borralos antes de exportar, o no importes nada y empezá de cero.

## Cómo funciona

| Tipo | Cuenta en ingresos/gastos | Afecta el saldo del socio |
|---|---|---|
| Gasto | Sí (gastos) | Resta a quien lo pagó |
| Ingreso | Sí (ingresos) | Suma a quien lo cobró |
| Compensación | No | Resta a quien da, suma a quien recibe |

- **Saldo del socio** = lo que cobró − lo que pagó ± las compensaciones del mes. Debajo del saldo aparece cuánto tiene que darle uno al otro para quedar a mano, es decir, con el mismo saldo.
- **Presupuesto por obra:** suma todos los meses. **Topes por categoría:** son por obra. Las barras se ponen ámbar arriba del 80% y rojas cuando se pasan.
- **Respaldo:** conviene tocar *Exportar JSON* de vez en cuando. Además, Supabase guarda la base en su servidor.

## Si algo falla

- **"Falta configurar Supabase":** revisá `config.js`.
- **"Mail o contraseña incorrectos":** revisá el usuario en Authentication → Users.
- **"Este mail no está habilitado como socio":** el mail no está en la tabla `socios`. Arreglalo en **Table Editor → socios**.
- **No se actualiza en vivo:** en **Database → Publications → supabase_realtime** tienen que estar tildadas `movimientos`, `clientes` y `topes`. Igual, al recargar la página siempre trae lo último.
