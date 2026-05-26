import Link from "next/link"
import { useRouter } from "next/router"
import {
  LayoutDashboard,
  Users,
  BookOpen,
  Calendar,
  ClipboardList,
  Building2,
  Bell,
  Search,
  UserCog,
} from "lucide-react"

const menuItems = [
  { name: "Dashboard", href: "/", icon: LayoutDashboard },
  { name: "Instructores", href: "/instructores", icon: Users },
  { name: "Fichas", href: "/fichas", icon: BookOpen, disabled: true },
  { name: "Horarios", href: "/horarios", icon: Calendar, disabled: true },
  { name: "Asignaciones", href: "/asignaciones", icon: ClipboardList, disabled: true },
  { name: "Ambientes", href: "/ambientes", icon: Building2, disabled: true },
  { name: "Alertas", href: "/alertas", icon: Bell, badge: 2, disabled: true },
  { name: "Consultas", href: "/consultas", icon: Search, disabled: true },
  { name: "Usuarios", href: "/usuarios", icon: UserCog, disabled: true },
]

export default function Sidebar() {
  const router = useRouter()

  return (
    <aside className="w-64 bg-sena text-white flex flex-col h-screen fixed left-0 top-0">
      {/* Logo y titulo */}
      <div className="p-6 border-b border-white/20">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center text-sena font-bold text-sm">
            SENA
          </div>
          <div>
            <h1 className="font-bold text-lg leading-tight">CONINS</h1>
            <p className="text-xs text-white/80">CDMC · SENA</p>
          </div>
        </div>
      </div>

      {/* Menu de navegacion */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {menuItems.map((item) => {
          const isActive = router.pathname === item.href
          const Icon = item.icon
          const isDisabled = item.disabled

          if (isDisabled) {
            return (
              <div
                key={item.name}
                className="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-white/40 cursor-not-allowed"
              >
                <Icon className="w-5 h-5" />
                <span>{item.name}</span>
                {item.badge && (
                  <span className="ml-auto bg-white/20 text-white/60 text-xs font-bold px-2 py-0.5 rounded-full">
                    {item.badge}
                  </span>
                )}
              </div>
            )
          }

          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                isActive
                  ? "bg-white/20 text-white shadow-sm"
                  : "text-white/80 hover:bg-white/10 hover:text-white"
              }`}
            >
              <Icon className="w-5 h-5" />
              <span>{item.name}</span>
              {item.badge && (
                <span className="ml-auto bg-white text-sena text-xs font-bold px-2 py-0.5 rounded-full">
                  {item.badge}
                </span>
              )}
            </Link>
          )
        })}
      </nav>

      {/* Footer del sidebar */}
      <div className="p-4 border-t border-white/20">
        <p className="text-xs text-white/60 text-center">
          CONINS v0.1 · CDMC SENA
        </p>
      </div>
    </aside>
  )
}
