import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import api from '../../api/axios';
import toast from 'react-hot-toast';
import StatusBadge from '../../components/StatusBadge';
import SeverityBadge from '../../components/SeverityBadge';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { FaThumbsUp, FaMapMarkerAlt, FaSpinner, FaCalendarAlt } from 'react-icons/fa';
import L from 'leaflet';

// Fix leaflet default icon issue
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';
let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

export default function ComplaintDetail() {
    const { id } = useParams();
    const [complaint, setComplaint] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDetail = async () => {
            try {
                const res = await api.get(`/complaints/${id}/`);
                setComplaint(res.data);
            } catch (err) {
                toast.error('Failed to load complaint details');
            } finally {
                setLoading(false);
            }
        };
        fetchDetail();
    }, [id]);

    const handleUpvote = async () => {
        try {
            const res = await api.post(`/complaints/${id}/upvote/`);
            setComplaint({ ...complaint, upvote_count: res.data.upvote_count });
            toast.success('Upvoted successfully!');
        } catch (err) {
            toast.error(err.response?.data?.error || 'Failed to upvote');
        }
    };

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;
    if (!complaint) return <div className="text-center mt-10 text-gray-500 font-bold">Complaint not found</div>;

    const steps = ['submitted', 'in_progress', 'resolved'];
    const currentStepIdx = steps.indexOf(complaint.status) === -1 ? 0 : steps.indexOf(complaint.status);

    return (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Left Column: Details & Images */}
            <div className="lg:col-span-2 space-y-6">
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                    <div className="flex justify-between items-start mb-4">
                        <div>
                            <h1 className="text-3xl font-extrabold text-gray-800">{complaint.complaint_number}</h1>
                            <div className="text-sm text-gray-500 flex items-center gap-2 mt-2 font-medium">
                                <FaCalendarAlt /> {new Date(complaint.submitted_at).toLocaleString()}
                            </div>
                        </div>
                        <StatusBadge status={complaint.status} />
                    </div>

                    <div className="flex flex-wrap gap-3 mb-6">
                        <span className="bg-gray-100 text-gray-700 px-3 py-1 rounded-full font-bold uppercase tracking-wide text-xs">
                            {complaint.issue_type}
                        </span>
                        <SeverityBadge severity={complaint.severity} />
                        {complaint.is_emergency && <span className="bg-red-500 text-white px-3 py-1 rounded-full font-bold uppercase tracking-wide text-xs">🚨 Emergency</span>}
                    </div>

                    <div className="bg-gray-50 p-5 rounded-xl border border-gray-100 mb-6">
                        <h3 className="font-bold text-gray-700 mb-2 uppercase tracking-wider text-xs">Description</h3>
                        <p className="text-gray-700 leading-relaxed font-medium">{complaint.description || 'No description provided.'}</p>
                    </div>

                    <h3 className="font-bold text-gray-700 mb-3 uppercase tracking-wider text-xs">Photos</h3>
                    {complaint.images && complaint.images.length > 0 ? (
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            {complaint.images.map((imgUrl, idx) => (
                                <img key={idx} src={imgUrl} alt={`Complaint ${idx}`} className="w-full h-48 object-cover rounded-xl shadow-sm border border-gray-200" />
                            ))}
                        </div>
                    ) : (
                        <div className="bg-gray-100 p-4 rounded-xl text-center text-gray-500 font-medium">No images uploaded</div>
                    )}
                </div>
            </div>

            {/* Right Column: Status, Upvote, Map */}
            <div className="space-y-6">
                {/* Severity Score Card */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                    <h3 className="font-bold text-gray-700 mb-4 uppercase tracking-wider text-xs">Severity Assessment</h3>
                    <div className="flex justify-between items-end mb-2">
                        <span className="text-5xl font-extrabold text-gray-800">{Math.round(complaint.severity_score)}</span>
                        <span className="text-gray-500 font-medium mb-1">/ 100</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-3 mt-4">
                        <div
                            className={`h-3 rounded-full transition-all duration-1000 ${complaint.severity_score >= 70 ? 'bg-red-500' : complaint.severity_score >= 40 ? 'bg-yellow-500' : 'bg-green-500'}`}
                            style={{ width: `${Math.min(100, Math.max(0, complaint.severity_score))}%` }}
                        ></div>
                    </div>
                </div>

                {/* Action / Upvote */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex items-center justify-between">
                    <div className="text-gray-700 font-bold">Show Support</div>
                    <button
                        onClick={handleUpvote}
                        className="flex items-center gap-2 bg-indigo-50 text-indigo-700 border border-indigo-200 hover:bg-indigo-100 px-6 py-3 rounded-xl font-bold transition-all shadow-sm"
                    >
                        <FaThumbsUp /> {complaint.upvote_count}
                    </button>
                </div>

                {/* Timeline */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                    <h3 className="font-bold text-gray-700 mb-6 uppercase tracking-wider text-xs">Status Timeline</h3>
                    <div className="space-y-6 relative before:absolute before:inset-0 before:ml-[11px] before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-gray-200 before:to-transparent">
                        {steps.map((step, idx) => {
                            const isActive = complaint.status === step;
                            const isPast = idx < currentStepIdx || complaint.status === 'resolved';
                            const color = isActive ? 'bg-indigo-600 ring-4 ring-indigo-100' : isPast ? 'bg-green-500' : 'bg-gray-300';

                            return (
                                <div key={step} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                                    <div className={`flex items-center justify-center w-6 h-6 rounded-full border-white border-2 bg-white shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10 ${color}`}></div>
                                    <div className="w-[calc(100%-4rem)] md:w-[calc(50%-2.5rem)] bg-white p-3 rounded-xl border border-gray-100 shadow-sm font-bold text-gray-700 text-sm uppercase">
                                        {step.replace('_', ' ')}
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* Location Map */}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                    <h3 className="font-bold text-gray-700 mb-4 uppercase tracking-wider text-xs flex items-center gap-2">
                        <FaMapMarkerAlt className="text-red-500" /> Location
                    </h3>
                    <p className="text-sm text-gray-600 mb-4 font-medium">{complaint.address || `${complaint.latitude}, ${complaint.longitude}`}</p>
                    <div className="h-48 w-full rounded-xl overflow-hidden border border-gray-200">
                        <MapContainer center={[complaint.latitude, complaint.longitude]} zoom={15} style={{ height: '100%', width: '100%' }}>
                            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                            <Marker position={[complaint.latitude, complaint.longitude]}>
                                <Popup>{complaint.issue_type}</Popup>
                            </Marker>
                        </MapContainer>
                    </div>
                </div>

            </div>
        </div>
    );
}
