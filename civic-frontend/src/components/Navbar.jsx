import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { FaCity, FaTrophy, FaSignOutAlt } from 'react-icons/fa';

export default function Navbar() {
    const { user, role, logout } = useAuth();

    if (!user) return null;

    return (
        <nav className="bg-white shadow-sm border-b px-6 py-4 flex justify-between items-center sticky top-0 z-50">
            <div className="flex items-center gap-6">
                <Link to={role === 'citizen' ? '/citizen' : '/authority'} className="text-2xl font-bold text-indigo-600 flex items-center gap-2 transition-transform hover:scale-105">
                    <FaCity /> CivicFix
                </Link>
                <div className="hidden md:flex items-center gap-6 text-gray-600 font-medium">
                    {role === 'citizen' ? (
                        <>
                            <Link to="/citizen" className="hover:text-indigo-600 transition-colors">Home</Link>
                            <Link to="/citizen/complaints" className="hover:text-indigo-600 transition-colors">My Reports</Link>
                            <Link to="/citizen/submit" className="hover:text-indigo-600 transition-colors">Report Issue</Link>
                            <Link to="/citizen/notifications" className="hover:text-indigo-600 transition-colors">Notifications</Link>
                        </>
                    ) : (
                        <>
                            <Link to="/authority" className="hover:text-indigo-600 transition-colors">Dashboard</Link>
                            <Link to="/authority/complaints" className="hover:text-indigo-600 transition-colors">All Complaints</Link>
                            <Link to="/authority/heatmap" className="hover:text-indigo-600 transition-colors">Heatmap</Link>
                        </>
                    )}
                </div>
            </div>

            <div className="flex items-center gap-4">
                {role === 'citizen' && (
                    <span className="bg-yellow-50 text-yellow-700 border border-yellow-200 px-3 py-1 rounded-full font-bold text-sm flex items-center gap-1.5 shadow-sm">
                        <FaTrophy className="text-yellow-500" /> {user.civic_points || 0} pts
                    </span>
                )}
                <span className="text-gray-700 font-bold hidden sm:block bg-gray-100 px-3 py-1 rounded-full">@{user.username}</span>
                <button
                    onClick={logout}
                    className="flex items-center gap-2 text-sm border border-gray-300 px-3 py-1.5 rounded-lg hover:bg-gray-50 hover:text-red-600 transition-colors text-gray-700 font-bold"
                >
                    <FaSignOutAlt /> Logout
                </button>
            </div>
        </nav>
    );
}
