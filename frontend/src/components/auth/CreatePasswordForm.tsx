import { useState } from "react"
import { Mail, Lock, Eye, EyeOff } from "lucide-react"

export default function CreatePasswordForm() {
  const [mostrarPassword, setMostrarPassword] = useState(false)
  const [mostrarConfirmar, setMostrarConfirmar] = useState(false)

  return (
    <div className="flex flex-col gap-4">

      {/* Texto descriptivo */}
      <p className="text-sm text-gray-500">
        Tu cuenta fue habilitada por un administrador. Ingresa tu correo y crea tu contraseña de acceso.
      </p>

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

      {/* Campo contraseña nueva */}
      <div>
        <label className="block text-sm font-semibold text-gray-800 mb-1">
          Contraseña nueva
        </label>
        <div className="flex items-center border border-gray-200 rounded-xl px-4 py-3 gap-3">
          <span className="text-gray-400"><Lock className="w-5 h-5 text-gray-400" /></span>
          <input
            type={mostrarPassword ? "text" : "password"}
            placeholder="Mínimo 8 caracteres"
            className="flex-1 outline-none text-sm text-gray-700 bg-transparent"
          />
          <button onClick={() => setMostrarPassword(!mostrarPassword)}
            className="text-gray-400 text-sm">
            {mostrarPassword ? <Eye /> : <EyeOff />}
          </button>
        </div>
      </div>

      {/* Campo confirmar contraseña */}
      <div>
        <label className="block text-sm font-semibold text-gray-800 mb-1">
          Confirmar contraseña
        </label>
        <div className="flex items-center border border-gray-200 rounded-xl px-4 py-3 gap-3">
          <span className="text-gray-400"><Lock className="w-5 h-5 text-gray-400" /></span>
          <input
            type={mostrarConfirmar ? "text" : "password"}
            placeholder="Repite tu contraseña"
            className="flex-1 outline-none text-sm text-gray-700 bg-transparent"
          />
          <button onClick={() => setMostrarConfirmar(!mostrarConfirmar)}
            className="text-gray-400 text-sm">
            {mostrarConfirmar ? <Eye /> : <EyeOff />}
          </button>
        </div>
      </div>

      {/* Botón */}
      <button className="w-full bg-green-500 hover:bg-green-600 text-white font-semibold py-3 rounded-xl transition-colors mt-2">
        Crear contraseña
      </button>

    </div>
  )
}
