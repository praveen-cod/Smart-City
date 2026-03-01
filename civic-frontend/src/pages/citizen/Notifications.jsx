import { useState, useEffect } from 'react';
import api from '../../api/axios';
import { FaBell, FaCheck, FaSpinner } from 'react-icons/fa';
import toast from 'react-hot-toast';

export default function Notifications() {
    const [notifications, setNotifications] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchNotifications();
    }, []);

    const fetchNotifications = async () => {
        try {
            const res = await api.get('/notifications/');
            setNotifications(res.data);
        } catch (err) {
            toast.error('Failed to load notifications');
        } finally {
            setLoading(false);
        }
    };

    const markAllRead = async () => {
        try {
            await api.patch('/notifications/');
            setNotifications(notifications.map(n => ({ ...n, is_read: true })));
            toast.success('All marked as read');
        } catch (err) {
            toast.error('Failed to mark read');
        }
    };

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;

    return (
        <div className="max-w-4xl mx-auto space-y-6">
            <div className="flex justify-between items-center bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800 flex items-center gap-2"><FaBell className="text-indigo-500" /> Notifications</h1>
                    <p className="text-gray-500 mt-1 font-medium">Updates on your civic reports</p>
                </div>
                {notifications.some(n => !n.is_read) && (
                    <button
                        onClick={markAllRead}
                        className="bg-indigo-50 text-indigo-700 hover:bg-indigo-100 border border-indigo-200 px-4 py-2 rounded-xl font-bold text-sm flex items-center gap-2 transition-colors"
                    >
                        <FaCheck /> Mark All Read
                    </button>
                )}
            </div>

            <div className="space-y-4">
                {notifications.length === 0 ? (
                    <div className="bg-white p-12 rounded-2xl text-center border border-gray-100">
                        <p className="text-gray-500 font-bold text-lg">No notifications yet 🎉</p>
                    </div>
                ) : (
                    notifications.map(n => (
                        <div
                            key={n.id}
                            className={`bg-white p-5 rounded-2xl shadow-sm border ${n.is_read ? 'border-gray-100' : 'border-l-4 border-l-blue-500 border-t-gray-100 border-r-gray-100 border-b-gray-100'} flex items-start gap-4 transition-all hover:shadow-md`}
                        >
                            <div className={`p-3 rounded-full ${n.is_read ? 'bg-gray-100 text-gray-400' : 'bg-blue-100 text-blue-600'}`}>
                                <FaBell className="text-xl" />
                            </div>
                            <div className="flex-1">
                                <p className={`text-gray-800 font-medium ${!n.is_read && 'font-bold'}`}>{n.message}</p>
                                <span className="text-xs text-gray-500 font-bold tracking-wide mt-2 inline-block">
                                    {new Date(n.created_at).toLocaleString()}
                                </span>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
