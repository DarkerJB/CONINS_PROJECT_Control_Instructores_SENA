import { createContext, useContext, useState, useCallback, ReactNode } from "react"
import ConfirmDialog from "@/components/ui/ConfirmDialog"

// Confirmacion global basada en promesa. Uso en cualquier handler de mutacion:
//   const confirm = useConfirm()
//   if (!(await confirm({ title, message }))) return
// Politica CONINS: crear / editar / borrar piden confirmacion (coordinacion y admin).
type ConfirmOptions = { title: string; message: string }
type ConfirmFn = (opts: ConfirmOptions) => Promise<boolean>

const ConfirmContext = createContext<ConfirmFn>(async () => true)

export function useConfirm(): ConfirmFn {
  return useContext(ConfirmContext)
}

export function ConfirmProvider({ children }: { children: ReactNode }) {
  const [pending, setPending] = useState<{ opts: ConfirmOptions; resolve: (v: boolean) => void } | null>(null)

  const confirm = useCallback<ConfirmFn>((opts) => {
    return new Promise<boolean>((resolve) => setPending({ opts, resolve }))
  }, [])

  return (
    <ConfirmContext.Provider value={confirm}>
      {children}
      {pending && (
        <ConfirmDialog
          title={pending.opts.title}
          message={pending.opts.message}
          onConfirm={() => { pending.resolve(true); setPending(null) }}
          onCancel={() => { pending.resolve(false); setPending(null) }}
        />
      )}
    </ConfirmContext.Provider>
  )
}
