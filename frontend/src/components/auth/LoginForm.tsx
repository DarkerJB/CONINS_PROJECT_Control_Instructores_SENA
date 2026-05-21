import { useState } from "react"
import { Mail, Lock, Eye, EyeOff, Loader2, AlertCircle } from "lucide-react"

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"

interface LoginFormProps {
  onSuccess: (token: string, user: any) => void
}

export default function LoginForm({ onSuccess }: LoginFormProps) {
  const [mostrarPassword, setMostrarPassword] = useState(false)
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)

    try {
      const res = await fetch(`${API_URL}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      })

      const data = await res.json()

      if (!res.ok) {
        setError(data.message || "Error al iniciar sesion")
        return
      }

      localStorage.setItem("token", data.data.token)
      localStorage.setItem("user", JSON.stringify(data.data.user))
      onSuccess(data.data.token, data.data.user)
    } catch {
      setError("Error de conexion con el servidor")
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4">

      {error && (
        <div className="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl">
          <AlertCircle className="w-4 h-4 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Campo correo */}
      <div>
        <label className="block text-sm font-semibold text-gray-800 mb-1">
          Correo electronico
        </label>
        <div className="flex items-center border border-gray-200 rounded-xl px-4 py-3 gap-3">
          <span className="text-gray-400"><Mail className="w-5 h-5 text-gray-400" /></span>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="tucorreo@ejemplo.com"
            required
            className="flex-1 outline-none text-sm text-gray-700 bg-transparent"
          />
        </div>
      </div>

      {/* Campo contraseña */}
      <div>
        <label className="block text-sm font-semibold text-gray-800 mb-1">
          Contraseña
        </label>
        <div className="flex items-center border border-gray-200 rounded-xl px-4 py-3 gap-3">
          <span className="text-gray-400"><Lock className="w-5 h-5 text-gray-400" /></span>
          <input
            type={mostrarPassword ? "text" : "password"}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            className="flex-1 outline-none text-sm text-gray-700 bg-transparent"
          />
          <button
            type="button"
            onClick={() => setMostrarPassword(!mostrarPassword)}
            className="text-gray-400 text-sm"
          >
            {mostrarPassword ? <Eye /> : <EyeOff />}
          </button>
        </div>
      </div>

      {/* Boton */}
      <button
        type="submit"
        disabled={loading}
        className="w-full bg-green-500 hover:bg-green-600 disabled:bg-green-300 text-white font-semibold py-3 rounded-xl transition-colors mt-2 flex items-center justify-center gap-2"
      >
        {loading ? (
          <>
            <Loader2 className="w-4 h-4 animate-spin" />
            Iniciando sesion...
          </>
        ) : (
          "Iniciar sesion"
        )}
      </button>

      {/* Link olvidaste contraseña */}
      <a href="#" className="text-center text-green-500 text-sm font-semibold hover:underline">
        Olvidaste tu contraseña?
      </a>

    </form>
  )
}
