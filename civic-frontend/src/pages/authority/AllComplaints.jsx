import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../../api/axios';
import StatusBadge from '../../components/StatusBadge';
import SeverityBadge from '../../components/SeverityBadge';
import { FaFilter, FaSearch, FaSpinner, FaArrowRight, FaThumbsUp } from 'react-icons/fa';

export default function AllComplaints() {
    const [complaints, setComplaints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [statusFilter, setStatusFilter] = useState('');
    const [typeFilter, setTypeFilter] = useState('');
    const [search, setSearch] = useState('');
    const navigate = useNavigate();

    useEffect(() => {
        const fetchComplaints = async () => {
            try {
                const res = await api.get('/complaints/');
                // Sort by severity score descending naturally
                const sorted = res.data.sort((a, b) => b.severity_score - a.severity_score);
                setComplaints(sorted);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchComplaints();
    }, []);

    const filtered = complaints.filter(c => {
        if (statusFilter && c.status !== statusFilter) return false;
        if (typeFilter && c.issue_type !== typeFilter) return false;
        if (search && !c.complaint_number.toLowerCase().includes(search.toLowerCase())) return false;
        return true;
    });

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;

    return (
        <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">All Complaints</h1>
                    <p className="text-gray-500 mt-1 font-medium">Manage and review all issues across the city.</p>
                </div>
            </div>

            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col sm:flex-row gap-4">
                <div className="flex-1 relative">
                    <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                    <input
                        type="text"
                        placeholder="Search by Complaint #..."
                        className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                    />
                </div>
                <div className="flex items-center gap-4 border-l pl-4 border-gray-200">
                    <FaFilter className="text-gray-400 hidden sm:block" />
                    <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)} className="border border-gray-200 rounded-lg px-3 py-2 outline-none font-bold text-gray-700 bg-white">
                        <option value="">All Statuses</option>
                        <option value="submitted">Submitted</option>
                        <option value="in_progress">In Progress</option>
                        <option value="resolved">Resolved</option>
                        <option value="rejected">Rejected</option>
                    </select>
                    <select value={typeFilter} onChange={e => setTypeFilter(e.target.value)} className="border border-gray-200 rounded-lg px-3 py-2 outline-none font-bold text-gray-700 bg-white min-w-[140px]">
                        <option value="">All Types</option>
                        <option value="pothole">Pothole</option>
                        <option value="garbage">Garbage</option>
                        <option value="streetlight">Streetlight</option>
                        <option value="water_leak">Water Leak</option>
                        <option value="drain">Drain</option>
                        <option value="other">Other</option>
                    </select>
                </div>
            </div>

            <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-500 font-bold uppercase tracking-wider text-xs border-b border-gray-200">
                                <th className="px-6 py-4">Complaint #</th>
                                <th className="px-6 py-4">Issue Type</th>
                                <th className="px-6 py-4">Severity / Score</th>
                                <th className="px-6 py-4">Status</th>
                                <th className="px-6 py-4 whitespace-nowrap"><FaThumbsUp className="inline" /></th>
                                <th className="px-6 py-4">Action</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {filtered.map(c => (
                                <tr key={c.id} className="hover:bg-gray-50 transition-colors">
                                    <td className="px-6 py-4 font-bold text-gray-800">
                                        {c.complaint_number}
                                        {c.is_emergency && <span className="ml-2 bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full uppercase tracking-widest align-middle">🚨 EMT</span>}
                                    </td>
                                    <td className="px-6 py-4 font-bold text-gray-600 uppercase text-xs">{c.issue_type}</td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-2">
                                            <SeverityBadge severity={c.severity} />
                                            <span className="text-gray-500 text-xs font-bold w-6">{Math.round(c.severity_score)}</span>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4"><StatusBadge status={c.status} /></td>
                                    <td className="px-6 py-4 font-bold text-gray-700">{c.upvote_count}</td>
                                    <td className="px-6 py-4">
                                        <button
                                            onClick={() => navigate(`/authority/complaints/${c.id}`)}
                                            className="text-indigo-600 hover:text-indigo-800 font-bold text-sm flex items-center gap-1 hover:underline outline-none"
                                        >
                                            Manage <FaArrowRight />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                            {filtered.length === 0 && (
                                <tr>
                                    <td colSpan="6" className="px-6 py-12 text-center text-gray-500 font-medium text-lg">
                                        No complaints match your filters.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
