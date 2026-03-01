import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import toast from 'react-hot-toast';
import api from '../api/axios';
import { FaCity, FaSpinner } from 'react-icons/fa';

export default function Login() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        try {
            const res = await api.post('/auth/login/', { username, password });
            const token = res.data.access;

            // Fetch user profile to get role
            const meRes = await api.get('/auth/me/', { headers: { Authorization: `Bearer ${token}` } });
            const user = meRes.data;

            login(token, user);
            toast.success('Logged in successfully!');

            if (user.role === 'citizen') {
                navigate('/citizen');
            } else {
                navigate('/authority');
            }
        } catch (err) {
            toast.error('Invalid credentials. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="max-w-md w-full bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
                <div className="text-center mb-8">
                    <h1 className="text-4xl font-extrabold text-indigo-600 flex items-center justify-center gap-3 mb-2">
                        <FaCity /> CivicFix
                    </h1>
                    <p className="text-gray-500 font-medium tracking-wide">Smart Civic Complaint Platform</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-5">
                    <div>
                        <label className="block text-sm font-bold text-gray-700 mb-1">Username</label>
                        <input
                            type="text"
                            required
                            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all outline-none"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            placeholder="Enter your username"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-bold text-gray-700 mb-1">Password</label>
                        <input
                            type="password"
                            required
                            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all outline-none"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="••••••••"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3.5 rounded-xl mt-4 transition-all shadow-md shadow-indigo-200 flex items-center justify-center gap-2 disabled:opacity-70"
                    >
                        {loading ? <FaSpinner className="animate-spin" /> : 'Sign In'}
                    </button>
                </form>

                <p className="text-center mt-6 text-gray-500 font-medium">
                    Don't have an account?{' '}
                    <Link to="/register" className="text-indigo-600 hover:text-indigo-800 font-bold underline decoration-2 underline-offset-4">
                        Register here
                    </Link>
                </p>
            </div>
        </div>
    );
}
