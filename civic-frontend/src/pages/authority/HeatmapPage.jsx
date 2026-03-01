import { useState, useEffect } from 'react';
import api from '../../api/axios';
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { FaMapMarkedAlt, FaSpinner } from 'react-icons/fa';

export default function HeatmapPage() {
    const [heatmap, setHeatmap] = useState([]);
    const [loading, setLoading] = useState(true);

    // Center on Hyderabad by default
    const defaultCenter = [17.3850, 78.4867];

    useEffect(() => {
        const fetchHeatmap = async () => {
            try {
                const res = await api.get('/dashboard/');
                setHeatmap(res.data.heatmap_data || []);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchHeatmap();
    }, []);

    const getMarkerColor = (score) => {
        if (score >= 70) return '#ef4444'; // red critical
        if (score >= 40) return '#f97316'; // orange moderate
        return '#22c55e'; // green low
    };

    if (loading) return <div className="flex justify-center items-center h-64"><FaSpinner className="animate-spin text-4xl text-indigo-500" /></div>;

    return (
        <div className="flex flex-col h-[calc(100vh-120px)] space-y-4">
            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center shrink-0">
                <h1 className="text-xl font-bold text-gray-800 flex items-center gap-3">
                    <FaMapMarkedAlt className="text-indigo-600" /> Live Complaint Heatmap
                </h1>
                <div className="flex gap-4 text-xs font-bold uppercase tracking-wider text-gray-600 bg-gray-50 px-4 py-2 rounded-lg border border-gray-100">
                    <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-red-500"></span> Critical (70+)</span>
                    <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-orange-500"></span> Moderate (40-69)</span>
                    <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-green-500"></span> Low (&lt;40)</span>
                </div>
            </div>

            <div className="flex-1 bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden relative z-0">
                <MapContainer center={defaultCenter} zoom={12} style={{ height: '100%', width: '100%' }}>
                    <TileLayer
                        url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
                        attribution='&copy; <a href="https://carto.com/">CARTO</a>'
                    />
                    {heatmap.map((pt, idx) => (
                        <CircleMarker
                            key={idx}
                            center={[pt.latitude, pt.longitude]}
                            pathOptions={{
                                fillColor: getMarkerColor(pt.severity_score),
                                color: getMarkerColor(pt.severity_score),
                                weight: 1,
                                fillOpacity: 0.6
                            }}
                            radius={Math.max(6, (pt.severity_score || 0) / 10)}
                        >
                            <Popup className="font-sans">
                                <div className="p-1">
                                    <div className="font-bold text-gray-800 uppercase tracking-widest text-xs mb-1">{pt.issue_type}</div>
                                    <div className="text-sm text-gray-600">Severity Match: <b className="text-gray-800">{Math.round(pt.severity_score)}</b></div>
                                    <div className="text-xs text-gray-500 mt-1">{pt.address}</div>
                                </div>
                            </Popup>
                        </CircleMarker>
                    ))}
                </MapContainer>
            </div>
        </div>
    );
}
