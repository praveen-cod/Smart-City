import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../../api/axios';
import { useAuth } from '../../context/AuthContext';
import ComplaintCard from '../../components/ComplaintCard';
import { FaCamera, FaListUl, FaBell, FaSpinner } from 'react-icons/fa';

export default function CitizenHome() {
    const { user } = useAuth();
    const [stats, setStats] = useState(null);
    const [recent, setRecent] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [dashRes, compRes] = await Promise.all([
                    api.get('/dashboard/'),
                    api.get('/complaints/mine/')
                ]);
                setStats(dashRes.data);
                setRecent(compRes.data.slice(0, 3));
            } catch (err) {
                console.error('Failed to load dashboard data', err);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    if (loading) {
        return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;
    }

    return (
        <div className="space-y-8">
            <div className="flex justify-between items-center bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Welcome back, {user.username} 👋</h1>
                    <p className="text-gray-500 mt-1">Ready to make your city better today?</p>
                </div>
                <div className="hidden sm:block bg-yellow-50 text-yellow-700 border border-yellow-200 px-4 py-2 rounded-xl font-bold text-lg shadow-sm">
                    🏅 {stats?.civic_points || 0} Civic Points
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col justify-center items-center text-center">
                    <h3 className="text-gray-500 font-medium mb-2">Total Reports</h3>
                    <p className="text-4xl font-extrabold text-indigo-600">{stats?.my_total || 0}</p>
                </div>
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col justify-center items-center text-center">
                    <h3 className="text-gray-500 font-medium mb-2">Resolved</h3>
                    <p className="text-4xl font-extrabold text-green-500">{stats?.my_resolved || 0}</p>
                </div>
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col justify-center items-center text-center">
                    <h3 className="text-gray-500 font-medium mb-2">Pending</h3>
                    <p className="text-4xl font-extrabold text-yellow-500">{stats?.my_pending || 0}</p>
                </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <Link to="/citizen/submit" className="bg-indigo-600 hover:bg-indigo-700 text-white p-4 rounded-xl font-bold flex flex-col items-center justify-center gap-2 transition-all shadow-md shadow-indigo-200">
                    <FaCamera className="text-2xl" /> Report an Issue
                </Link>
                <Link to="/citizen/complaints" className="bg-white hover:bg-gray-50 text-indigo-600 border border-indigo-100 p-4 rounded-xl font-bold flex flex-col items-center justify-center gap-2 transition-all shadow-sm">
                    <FaListUl className="text-2xl" /> My Complaints
                </Link>
                <Link to="/citizen/notifications" className="bg-white hover:bg-gray-50 text-indigo-600 border border-indigo-100 p-4 rounded-xl font-bold flex flex-col items-center justify-center gap-2 transition-all shadow-sm">
                    <FaBell className="text-2xl" /> Notifications
                </Link>
            </div>

            <div>
                <h2 className="text-xl font-bold text-gray-800 mb-4 flex items-center justify-between">
                    Recent Complaints
                    <Link to="/citizen/complaints" className="text-sm font-medium text-indigo-600 hover:underline">View All →</Link>
                </h2>
                {recent.length === 0 ? (
                    <div className="bg-white p-8 rounded-2xl text-center border border-gray-100">
                        <p className="text-gray-500">No complaints yet. Report your first issue! 📷</p>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {recent.map(c => (
                            <ComplaintCard key={c.id} complaint={c} onClickPath={`/citizen/complaints/${c.id}`} />
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
