import { useState, useEffect } from 'react';
import api from '../../api/axios';
import ComplaintCard from '../../components/ComplaintCard';
import { FaFilter, FaSpinner } from 'react-icons/fa';

export default function MyComplaints() {
    const [complaints, setComplaints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('All');

    useEffect(() => {
        const fetchComplaints = async () => {
            try {
                const res = await api.get('/complaints/mine/');
                setComplaints(res.data);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchComplaints();
    }, []);

    const statuses = ['All', 'submitted', 'in_progress', 'resolved', 'rejected'];

    const filtered = filter === 'All'
        ? complaints
        : complaints.filter(c => c.status === filter);

    if (loading) {
        return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;
    }

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">My Reports</h1>
                    <p className="text-gray-500 mt-1">Track the status of your civic complaints.</p>
                </div>

                <div className="flex items-center gap-2 overflow-x-auto pb-2 sm:pb-0 w-full sm:w-auto">
                    <FaFilter className="text-gray-400 mr-2" />
                    {statuses.map(s => (
                        <button
                            key={s}
                            onClick={() => setFilter(s)}
                            className={`px-4 py-2 rounded-xl text-sm font-bold uppercase tracking-wider whitespace-nowrap transition-colors ${filter === s ? 'bg-indigo-600 text-white shadow-md' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
                        >
                            {s.replace('_', ' ')}
                        </button>
                    ))}
                </div>
            </div>

            {filtered.length === 0 ? (
                <div className="bg-white p-12 rounded-2xl text-center border border-gray-100 shadow-sm">
                    <p className="text-gray-500 font-medium text-lg">No complaints found. Report your first issue! 📷</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filtered.map(c => (
                        <ComplaintCard key={c.id} complaint={c} onClickPath={`/citizen/complaints/${c.id}`} />
                    ))}
                </div>
            )}
        </div>
    );
}
