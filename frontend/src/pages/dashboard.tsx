import { useEffect, useState } from "react"
import { useRouter } from "next/router"

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api"

interface Instructor {
  id: number
  nombre: string
  email: string
  tipo_area: string
  tipo_contrato: string
  activo: boolean
  roles: string
}

export default function Dashboard() {
  const router = useRouter()
  const [user, setUser] = useState<any>(null)
  const [instructores, setInstructores] = useState<Instructor[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem("token")
    const userData = localStorage.getItem("conins_user")

    if (!token || !userData) {
      router.push("/auth")
      return
    }

    setUser(JSON.parse(userData))

    fetch(`${API_URL}/instructores`, {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setInstructores(data.data)
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [router])

  const handleLogout = () => {
    localStorage.removeItem("token")
    localStorage.removeItem("conins_user")
    router.push("/auth")
  }

  if (!user || loading) return null

  return (
    <main className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900">CONINS</h1>
        <div className="flex items-center gap-4">
          <span className="text-sm text-gray-600">{user.nombre}</span>
          <button
            onClick={handleLogout}
            className="text-sm text-red-600 hover:text-red-700 font-medium"
          >
            Cerrar sesion
          </button>
        </div>
      </header>

      {/* Content */}
      <div className="max-w-6xl mx-auto px-6 py-8">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Hola, {user.nombre}
        </h2>
        <p className="text-gray-500 mb-8">
          {user.roles?.join(", ")}
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-1">Instructores</h3>
            <p className="text-3xl font-bold text-gray-900">{instructores.length}</p>
          </div>
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-1">Tecnicos</h3>
            <p className="text-3xl font-bold text-gray-900">
              {instructores.filter((i) => i.tipo_area === "tecnica").length}
            </p>
          </div>
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="text-sm font-medium text-gray-500 mb-1">Transversales</h3>
            <p className="text-3xl font-bold text-gray-900">
              {instructores.filter((i) => i.tipo_area === "transversal").length}
            </p>
          </div>
        </div>

        {/* Instructores list */}
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">Lista de Instructores</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th className="text-left px-6 py-3 font-medium text-gray-600">Nombre</th>
                  <th className="text-left px-6 py-3 font-medium text-gray-600">Email</th>
                  <th className="text-left px-6 py-3 font-medium text-gray-600">Area</th>
                  <th className="text-left px-6 py-3 font-medium text-gray-600">Contrato</th>
                  <th className="text-left px-6 py-3 font-medium text-gray-600">Estado</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {instructores.map((inst) => (
                  <tr key={inst.id} className="hover:bg-gray-50">
                    <td className="px-6 py-3 text-gray-900 font-medium">{inst.nombre}</td>
                    <td className="px-6 py-3 text-gray-500">{inst.email}</td>
                    <td className="px-6 py-3">
                      <span
                        className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                          inst.tipo_area === "tecnica"
                            ? "bg-blue-50 text-blue-700"
                            : "bg-purple-50 text-purple-700"
                        }`}
                      >
                        {inst.tipo_area}
                      </span>
                    </td>
                    <td className="px-6 py-3 text-gray-500">{inst.tipo_contrato}</td>
                    <td className="px-6 py-3">
                      <span
                        className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                          inst.activo
                            ? "bg-green-50 text-green-700"
                            : "bg-red-50 text-red-700"
                        }`}
                      >
                        {inst.activo ? "Activo" : "Inactivo"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  )
}
