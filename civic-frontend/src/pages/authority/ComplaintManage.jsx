import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../../api/axios';
import toast from 'react-hot-toast';
import StatusBadge from '../../components/StatusBadge';
import SeverityBadge from '../../components/SeverityBadge';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { FaSpinner, FaCalendarAlt, FaExclamationTriangle, FaThumbsUp, FaCheck, FaArrowLeft } from 'react-icons/fa';

export default function ComplaintManage() {
    const { id } = useParams();
    const navigate = useNavigate();
    const [complaint, setComplaint] = useState(null);
    const [loading, setLoading] = useState(true);
    const [status, setStatus] = useState('');
    const [updating, setUpdating] = useState(false);

    useEffect(() => {
        const fetchDetail = async () => {
            try {
                const res = await api.get(`/complaints/${id}/`);
                setComplaint(res.data);
                setStatus(res.data.status);
            } catch (err) {
                toast.error('Failed to load complaint');
            } finally {
                setLoading(false);
            }
        };
        fetchDetail();
    }, [id]);

    const handleStatusUpdate = async (e) => {
        e.preventDefault();
        setUpdating(true);
        try {
            await api.patch(`/complaints/${id}/status/`, { status });
            setComplaint({ ...complaint, status });
            toast.success('Status updated successfully!');
        } catch (err) {
            toast.error('Failed to update status');
        } finally {
            setUpdating(false);
        }
    };

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;
    if (!complaint) return <div className="text-center mt-10">Not found</div>;

    const steps = ['submitted', 'in_progress', 'resolved'];
    const currentStepIdx = steps.indexOf(complaint.status) === -1 ? 0 : steps.indexOf(complaint.status);

    return (
        <div className="space-y-6">
            <button onClick={() => navigate('/authority/complaints')} className="text-gray-500 hover:text-indigo-600 font-bold flex items-center gap-2 transition-colors">
                <FaArrowLeft /> Back to All Complaints
            </button>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left: Info */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                        <div className="flex justify-between items-start mb-4">
                            <div>
                                <h1 className="text-3xl font-extrabold text-gray-800 flex items-center gap-3">
                                    {complaint.complaint_number}
                                    {complaint.is_emergency && <span className="bg-red-500 text-white text-xs px-2 py-1 rounded-md uppercase tracking-widest bg-pulse animate-pulse">Emergency</span>}
                                </h1>
                                <div className="text-sm text-gray-500 flex items-center gap-2 mt-2 font-medium">
                                    <FaCalendarAlt /> Submitted {new Date(complaint.submitted_at).toLocaleString()}
                                </div>
                            </div>
                            <StatusBadge status={complaint.status} />
                        </div>

                        <div className="flex flex-wrap gap-3 mb-6">
                            <span className="bg-gray-100 text-gray-700 px-3 py-1 rounded-full font-bold uppercase tracking-wide text-xs">
                                {complaint.issue_type}
                            </span>
                            <SeverityBadge severity={complaint.severity} />
                        </div>

                        <div className="bg-gray-50 p-5 rounded-xl border border-gray-100 mb-6">
                            <h3 className="font-bold text-gray-700 mb-2 uppercase tracking-wider text-xs">Description</h3>
                            <p className="text-gray-700 leading-relaxed font-medium">{complaint.description || 'No description provided.'}</p>
                        </div>

                        <div className="bg-gray-50 p-5 rounded-xl border border-gray-100 mb-6">
                            <h3 className="font-bold text-gray-700 mb-2 uppercase tracking-wider text-xs">Reporter</h3>
                            <p className="font-medium text-gray-800">
                                👤 {complaint.user_info?.username || complaint.user?.username || 'Unknown'}
                                <span className="text-gray-500 text-sm ml-2">({complaint.user_info?.role || complaint.user?.role || 'user'})</span>
                            </p>
                        </div>

                        <h3 className="font-bold text-gray-700 mb-3 uppercase tracking-wider text-xs">Evidence Photos</h3>
                        {complaint.images && complaint.images.length > 0 ? (
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                                {complaint.images.map((imgUrl, idx) => (
                                    <a href={imgUrl} target="_blank" rel="noreferrer" key={idx}>
                                        <img src={imgUrl} alt={`Evidence ${idx}`} className="w-full h-32 object-cover rounded-xl shadow-sm border border-gray-200 hover:opacity-90 transition-opacity" />
                                    </a>
                                ))}
                            </div>
                        ) : (
                            <div className="bg-gray-100 p-4 rounded-xl text-center text-gray-500 font-medium">No images uploaded</div>
                        )}
                    </div>
                </div>

                {/* Right: Actions */}
                <div className="space-y-6">
                    {/* Action Panel */}
                    <div className="bg-white rounded-2xl shadow-sm border-2 border-indigo-100 p-6 relative overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-1 bg-indigo-500"></div>
                        <h3 className="font-bold text-gray-800 mb-6 flex items-center gap-2 text-lg">
                            <FaCheck className="text-indigo-500" /> Manage Status
                        </h3>
                        <form onSubmit={handleStatusUpdate} className="space-y-4">
                            <div>
                                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-2">Update Status To</label>
                                <select
                                    value={status}
                                    onChange={(e) => setStatus(e.target.value)}
                                    className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none font-bold text-gray-700 bg-gray-50"
                                >
                                    <option value="submitted">Submitted</option>
                                    <option value="in_progress">In Progress</option>
                                    <option value="resolved">Resolved</option>
                                    <option value="rejected">Rejected</option>
                                </select>
                            </div>
                            <button
                                type="submit"
                                disabled={updating || status === complaint.status}
                                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3.5 rounded-xl transition-all shadow-md shadow-indigo-200 disabled:opacity-50 flex items-center justify-center gap-2"
                            >
                                {updating ? <FaSpinner className="animate-spin" /> : 'Apply Status Update'}
                            </button>
                        </form>
                    </div>

                    {/* Stats Box */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex justify-between items-center">
                        <div>
                            <h3 className="text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Severity Score</h3>
                            <span className="text-3xl font-extrabold text-gray-800 flex items-center gap-2">
                                {Math.round(complaint.severity_score)} <FaExclamationTriangle className={complaint.severity_score >= 70 ? 'text-red-500' : 'text-yellow-500'} />
                            </span>
                        </div>
                        <div className="text-right">
                            <h3 className="text-xs font-bold text-gray-500 uppercase tracking-widest mb-1">Upvotes</h3>
                            <span className="text-3xl font-extrabold text-indigo-600 flex items-center justify-end gap-2">
                                <FaThumbsUp /> {complaint.upvote_count}
                            </span>
                        </div>
                    </div>

                    {/* Timeline Box */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hidden lg:block">
                        <h3 className="font-bold text-gray-700 mb-6 uppercase tracking-wider text-xs">Status Timeline</h3>
                        <div className="space-y-6 relative before:absolute before:inset-0 before:ml-[11px] before:-translate-x-px before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-gray-200 before:to-transparent">
                            {steps.map((step, idx) => {
                                const isActive = complaint.status === step;
                                const isPast = idx < currentStepIdx || complaint.status === 'resolved';
                                const color = isActive ? 'bg-indigo-600 ring-4 ring-indigo-100' : isPast ? 'bg-green-500' : 'bg-gray-300';

                                return (
                                    <div key={step} className="relative flex items-center justify-between group is-active">
                                        <div className={`flex items-center justify-center w-6 h-6 rounded-full border-white border-2 bg-white shadow shrink-0 z-10 ${color}`}></div>
                                        <div className="w-[calc(100%-3rem)] bg-white p-2 rounded border border-gray-100 shadow-sm font-bold text-gray-700 text-xs uppercase">
                                            {step.replace('_', ' ')}
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                </div>
            </div>
        </div>
    );
}
