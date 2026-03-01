import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../../api/axios';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import { FaClipboardList, FaCheckCircle, FaHourglassHalf, FaExclamationTriangle, FaChartBar, FaMapMarkedAlt, FaSpinner } from 'react-icons/fa';

export default function AuthorityDashboard() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const res = await api.get('/dashboard/');
                setStats(res.data);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchStats();
    }, []);

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;

    const COLORS = ['#4f46e5', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'];
    const PIE_COLORS = {
        submitted: '#3b82f6',
        in_progress: '#f59e0b',
        resolved: '#10b981',
        rejected: '#ef4444'
    };

    const statusData = stats?.status_stats?.map(s => ({ name: s.status, value: s.count })) || [];
    const issueData = stats?.issue_type_stats?.map(i => ({ name: i.issue_type, count: i.count })) || [];

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Authority Dashboard</h1>
                    <p className="text-gray-500 mt-1 font-medium">City-wide complaint overview</p>
                </div>
                <div className="flex gap-4">
                    <Link to="/authority/complaints" className="bg-white border border-gray-200 text-gray-700 hover:bg-gray-50 px-4 py-2 rounded-xl font-bold flex items-center gap-2 shadow-sm transition-all"><FaClipboardList className="text-indigo-500" /> All Complaints</Link>
                    <Link to="/authority/heatmap" className="bg-indigo-600 text-white hover:bg-indigo-700 px-4 py-2 rounded-xl font-bold flex items-center gap-2 shadow-sm shadow-indigo-200 transition-all"><FaMapMarkedAlt /> View Heatmap</Link>
                </div>
            </div>

            <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-center">
                    <FaClipboardList className="text-3xl text-indigo-500 mb-2" />
                    <h3 className="text-gray-500 font-bold uppercase tracking-wider text-xs mb-1">Total</h3>
                    <p className="text-3xl font-extrabold text-gray-800">{stats?.total || 0}</p>
                </div>
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-center">
                    <FaCheckCircle className="text-3xl text-green-500 mb-2" />
                    <h3 className="text-gray-500 font-bold uppercase tracking-wider text-xs mb-1">Resolved</h3>
                    <p className="text-3xl font-extrabold text-gray-800">{stats?.resolved || 0}</p>
                </div>
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-center">
                    <FaHourglassHalf className="text-3xl text-yellow-500 mb-2" />
                    <h3 className="text-gray-500 font-bold uppercase tracking-wider text-xs mb-1">Pending</h3>
                    <p className="text-3xl font-extrabold text-gray-800">{stats?.pending || 0}</p>
                </div>
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-red-100 flex flex-col items-center bg-red-50">
                    <FaExclamationTriangle className="text-3xl text-red-500 mb-2" />
                    <h3 className="text-red-700 font-bold uppercase tracking-wider text-xs mb-1">Critical</h3>
                    <p className="text-3xl font-extrabold text-red-700">{stats?.critical || 0}</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-96 flex flex-col">
                    <h3 className="text-gray-800 font-bold mb-6 flex items-center gap-2"><FaChartBar className="text-indigo-500" /> By Issue Type</h3>
                    <div className="flex-1 min-h-0">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={issueData}>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
                                <XAxis dataKey="name" tick={{ fill: '#6B7280', fontSize: 12 }} axisLine={false} tickLine={false} />
                                <YAxis tick={{ fill: '#6B7280', fontSize: 12 }} axisLine={false} tickLine={false} />
                                <Tooltip cursor={{ fill: '#F3F4F6' }} contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }} />
                                <Bar dataKey="count" radius={[4, 4, 0, 0]}>
                                    {issueData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                    ))}
                                </Bar>
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-96 flex flex-col relative">
                    <h3 className="text-gray-800 font-bold mb-2 flex items-center gap-2"><FaChartBar className="text-indigo-500" /> Status Distribution</h3>
                    <div className="absolute top-6 right-6 flex flex-col items-end">
                        <span className="text-sm font-bold text-gray-500 uppercase tracking-wider">Resolution Rate</span>
                        <span className="text-2xl font-extrabold text-green-500">{stats?.resolution_rate || 0}%</span>
                    </div>
                    <div className="flex-1 min-h-0 mt-4">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={statusData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={80}
                                    outerRadius={110}
                                    paddingAngle={5}
                                    dataKey="value"
                                >
                                    {statusData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={PIE_COLORS[entry.name] || COLORS[index % COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }} />
                                <Legend iconType="circle" wrapperStyle={{ fontSize: '14px', fontWeight: '600', color: '#4B5563' }} formatter={(val) => val.replace('_', ' ').toUpperCase()} />
                            </PieChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>
        </div>
    );
}
