import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Navbar from './components/Navbar';

import Login from './pages/Login';
import Register from './pages/Register';

// Citizen Pages
import CitizenHome from './pages/citizen/CitizenHome';
import SubmitComplaint from './pages/citizen/SubmitComplaint';
import MyComplaints from './pages/citizen/MyComplaints';
import ComplaintDetail from './pages/citizen/ComplaintDetail';
import Notifications from './pages/citizen/Notifications';

// Authority Pages
import AuthorityDashboard from './pages/authority/AuthorityDashboard';
import AllComplaints from './pages/authority/AllComplaints';
import ComplaintManage from './pages/authority/ComplaintManage';
import HeatmapPage from './pages/authority/HeatmapPage';

function AppLayout({ children }) {
  return (
    <div className="min-h-screen flex flex-col font-sans text-gray-800 bg-gray-50">
      <Navbar />
      <main className="flex-grow p-4 md:p-8 max-w-7xl mx-auto w-full">
        {children}
      </main>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Toaster position="top-right" />
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          <Route path="/citizen/*" element={
            <ProtectedRoute allowedRoles={['citizen']}>
              <AppLayout>
                <Routes>
                  <Route path="" element={<CitizenHome />} />
                  <Route path="submit" element={<SubmitComplaint />} />
                  <Route path="complaints" element={<MyComplaints />} />
                  <Route path="complaints/:id" element={<ComplaintDetail />} />
                  <Route path="notifications" element={<Notifications />} />
                </Routes>
              </AppLayout>
            </ProtectedRoute>
          } />

          <Route path="/authority/*" element={
            <ProtectedRoute allowedRoles={['authority', 'admin']}>
              <AppLayout>
                <Routes>
                  <Route path="" element={<AuthorityDashboard />} />
                  <Route path="complaints" element={<AllComplaints />} />
                  <Route path="complaints/:id" element={<ComplaintManage />} />
                  <Route path="heatmap" element={<HeatmapPage />} />
                </Routes>
              </AppLayout>
            </ProtectedRoute>
          } />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
