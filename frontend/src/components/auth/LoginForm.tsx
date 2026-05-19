import { useState } from "react"
import { Mail, Lock, Eye, EyeOff } from "lucide-react"

export default function LoginForm() {
  const [mostrarPassword, setMostrarPassword] = useState(false)

  return (
    <div className="flex flex-col gap-4">

      {/* Campo correo */}
      <div>
        <label className="block text-sm font-semibold text-gray-800 mb-1">
          Correo electrónico
        </label>
        <div className="flex items-center border border-gray-200 rounded-xl px-4 py-3 gap-3">
          <span className="text-gray-400"><Mail className="w-5 h-5 text-gray-400" /></span>
          <input
            type="email"
            placeholder="tucorreo@ejemplo.com"
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
            placeholder="••••••••"
            className="flex-1 outline-none text-sm text-gray-700 bg-transparent"
          />
          <button
            onClick={() => setMostrarPassword(!mostrarPassword)}
            className="text-gray-400 text-sm"
          >
            {mostrarPassword ? <Eye /> : <EyeOff />}
          </button>
        </div>
      </div>

      {/* Botón */}
      <button className="w-full bg-green-500 hover:bg-green-600 text-white font-semibold py-3 rounded-xl transition-colors mt-2">
        Iniciar sesión
      </button>

      {/* Link olvidaste contraseña */}
      <a href="#" className="text-center text-green-500 text-sm font-semibold hover:underline">
        ¿Olvidaste tu contraseña?
      </a>

    </div>
  )
}
