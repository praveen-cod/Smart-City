import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../../api/axios';
import toast from 'react-hot-toast';
import { FaMapMarkerAlt, FaSpinner, FaCloudUploadAlt } from 'react-icons/fa';

export default function SubmitComplaint() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        issue_type: 'pothole',
        severity: 'low',
        is_emergency: false,
        description: '',
        address: '',
        latitude: '',
        longitude: ''
    });
    const [files, setFiles] = useState([]);
    const [previewUrls, setPreviewUrls] = useState([]);

    const handleInputChange = (e) => {
        const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
        setFormData({ ...formData, [e.target.name]: value });
    };

    const handleFileChange = (e) => {
        const selectedFiles = Array.from(e.target.files);
        setFiles(selectedFiles);

        // Generate previews
        const urls = selectedFiles.map(file => URL.createObjectURL(file));
        setPreviewUrls(urls);
    };

    const getLocation = () => {
        if (!navigator.geolocation) {
            toast.error('Geolocation is not supported by your browser');
            return;
        }
        toast.loading('Fetching location...', { id: 'geo' });
        navigator.geolocation.getCurrentPosition(
            (pos) => {
                setFormData({
                    ...formData,
                    latitude: pos.coords.latitude.toFixed(6),
                    longitude: pos.coords.longitude.toFixed(6)
                });
                toast.success('Location found!', { id: 'geo' });
            },
            () => {
                toast.error('Failed to get location. Please enter manually.', { id: 'geo' });
            }
        );
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (files.length === 0) {
            toast.error('Please select at least one photo');
            return;
        }

        setLoading(true);
        const data = new FormData();
        Object.keys(formData).forEach(key => data.append(key, formData[key]));
        files.forEach(file => data.append('images', file));

        try {
            const res = await api.post('/complaints/submit/', data, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            if (res.data.is_duplicate) {
                toast.error('Similar complaint found! Your report boosted its priority.', { duration: 5000 });
            } else {
                toast.success(`Complaint submitted! ID: ${res.data.complaint_number}`);
            }

            setTimeout(() => navigate('/citizen/complaints'), 2000);
        } catch (err) {
            toast.error(err.response?.data?.error || 'Failed to submit complaint');
            setLoading(false);
        }
    };

    return (
        <div className="max-w-2xl mx-auto bg-white rounded-2xl shadow-sm border border-gray-100 p-6 md:p-8">
            <h1 className="text-2xl font-bold text-gray-800 mb-6 border-b pb-4">Report an Issue</h1>

            <form onSubmit={handleSubmit} className="space-y-8">
                {/* Step 1: Photos */}
                <section>
                    <h2 className="text-lg font-bold text-gray-700 mb-3 flex items-center gap-2"><span className="bg-indigo-100 text-indigo-700 w-6 h-6 rounded-full flex items-center justify-center text-sm">1</span> Upload Photos</h2>
                    <div className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:bg-gray-50 flex flex-col items-center justify-center cursor-pointer relative transition-colors">
                        <input
                            type="file"
                            multiple
                            accept="image/*"
                            onChange={handleFileChange}
                            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                        />
                        <FaCloudUploadAlt className="text-4xl text-gray-400 mb-3" />
                        <p className="text-gray-600 font-medium">Click or drag photos here</p>
                        <p className="text-sm text-gray-400 mt-1">First photo will be the primary image</p>
                    </div>
                    {previewUrls.length > 0 && (
                        <div className="mt-4 flex gap-3 overflow-x-auto pb-2">
                            {previewUrls.map((url, i) => (
                                <img key={i} src={url} alt={`Preview ${i}`} className="h-24 w-24 object-cover rounded-lg border border-gray-200 shadow-sm" />
                            ))}
                        </div>
                    )}
                </section>

                {/* Step 2: Location */}
                <section>
                    <h2 className="text-lg font-bold text-gray-700 mb-3 flex items-center gap-2"><span className="bg-indigo-100 text-indigo-700 w-6 h-6 rounded-full flex items-center justify-center text-sm">2</span> Location</h2>
                    <div className="bg-gray-50 p-4 rounded-xl border border-gray-100 space-y-4">
                        <button type="button" onClick={getLocation} className="w-full bg-white border border-gray-300 hover:bg-gray-100 text-gray-700 font-bold py-2 px-4 rounded-lg flex items-center justify-center gap-2 shadow-sm transition-all">
                            <FaMapMarkerAlt className="text-red-500" /> Use My Exact Location
                        </button>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Latitude</label>
                                <input type="number" step="any" name="latitude" required value={formData.latitude} onChange={handleInputChange} className="w-full px-3 py-2 rounded-lg border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none" placeholder="e.g. 17.3850" />
                            </div>
                            <div>
                                <label className="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Longitude</label>
                                <input type="number" step="any" name="longitude" required value={formData.longitude} onChange={handleInputChange} className="w-full px-3 py-2 rounded-lg border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none" placeholder="e.g. 78.4867" />
                            </div>
                        </div>
                        <div>
                            <label className="block text-xs font-bold text-gray-500 uppercase tracking-wide mb-1">Street Address / Landmark</label>
                            <input type="text" name="address" value={formData.address} onChange={handleInputChange} className="w-full px-3 py-2 rounded-lg border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none" placeholder="Nearby landmarks?" />
                        </div>
                    </div>
                </section>

                {/* Step 3: Details */}
                <section>
                    <h2 className="text-lg font-bold text-gray-700 mb-3 flex items-center gap-2"><span className="bg-indigo-100 text-indigo-700 w-6 h-6 rounded-full flex items-center justify-center text-sm">3</span> Details</h2>
                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-1">Issue Type</label>
                            <select name="issue_type" value={formData.issue_type} onChange={handleInputChange} className="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none bg-white">
                                <option value="pothole">🕳️ Pothole</option>
                                <option value="garbage">🗑️ Garbage</option>
                                <option value="streetlight">💡 Broken Streetlight</option>
                                <option value="water_leak">💧 Water Leak</option>
                                <option value="drain">🌊 Damaged Drain</option>
                                <option value="other">❓ Other</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Severity</label>
                            <div className="flex bg-gray-100 p-1 rounded-xl">
                                {['low', 'moderate', 'critical'].map(sev => (
                                    <button
                                        key={sev}
                                        type="button"
                                        onClick={() => setFormData({ ...formData, severity: sev })}
                                        className={`flex-1 py-2 text-sm font-bold rounded-lg uppercase tracking-wider transition-all ${formData.severity === sev ? (sev === 'low' ? 'bg-green-500 text-white shadow' : sev === 'moderate' ? 'bg-yellow-500 text-white shadow' : 'bg-red-500 text-white shadow') : 'text-gray-500 hover:bg-gray-200'}`}
                                    >
                                        {sev}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-1">Description</label>
                            <textarea name="description" rows="3" value={formData.description} onChange={handleInputChange} className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-indigo-500 outline-none resize-none" placeholder="Provide more context..."></textarea>
                        </div>

                        <label className="flex items-center gap-3 p-4 bg-red-50 text-red-700 border border-red-100 rounded-xl cursor-pointer hover:bg-red-100 transition-colors">
                            <input type="checkbox" name="is_emergency" checked={formData.is_emergency} onChange={handleInputChange} className="w-5 h-5 accent-red-600 cursor-pointer" />
                            <span className="font-bold">⚠️ Mark as Emergency Response Needed</span>
                        </label>
                    </div>
                </section>

                <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-4 rounded-xl text-lg shadow-md shadow-indigo-200 transition-all flex items-center justify-center gap-2 disabled:opacity-70 mt-4"
                >
                    {loading ? <FaSpinner className="animate-spin" /> : 'Submit Complaint →'}
                </button>
            </form>
        </div>
    );
}
