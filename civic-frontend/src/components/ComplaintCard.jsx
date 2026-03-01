import { useNavigate } from 'react-router-dom';
import StatusBadge from './StatusBadge';
import SeverityBadge from './SeverityBadge';
import { FaThumbsUp } from 'react-icons/fa';

export default function ComplaintCard({ complaint, onClickPath }) {
    const navigate = useNavigate();
    const date = new Date(complaint.submitted_at).toLocaleDateString();

    return (
        <div
            className="bg-white rounded-xl shadow-md p-4 cursor-pointer hover:shadow-lg transition-all border border-gray-100 flex flex-col"
            onClick={() => navigate(onClickPath)}
        >
            <div className="flex justify-between items-start mb-3">
                <h3 className="text-lg font-bold text-gray-800">{complaint.complaint_number}</h3>
                <StatusBadge status={complaint.status} />
            </div>

            <div className="flex items-center gap-2 mb-4">
                <span className="text-xs font-bold text-gray-600 bg-gray-100 px-2 py-1 rounded uppercase tracking-wider">
                    {complaint.issue_type}
                </span>
                <SeverityBadge severity={complaint.severity} />
                {complaint.is_emergency && (
                    <span className="text-xs font-bold text-white bg-red-500 px-2 py-1 rounded uppercase tracking-wider">
                        🚨 Emergency
                    </span>
                )}
            </div>

            <div className="flex-grow mb-4">
                <div className="flex justify-between text-xs text-gray-500 mb-1 font-medium">
                    <span>Severity Score</span>
                    <span>{Math.round(complaint.severity_score)}/100</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                        className={`h-2 rounded-full transition-all duration-500 ${complaint.severity_score >= 70 ? 'bg-red-500' : complaint.severity_score >= 40 ? 'bg-yellow-500' : 'bg-green-500'}`}
                        style={{ width: `${Math.min(100, Math.max(0, complaint.severity_score))}%` }}
                    ></div>
                </div>
            </div>

            <div className="flex justify-between items-center text-sm text-gray-500 border-t pt-3 mt-auto">
                <span>{date}</span>
                <div className="flex items-center gap-1.5 font-bold text-gray-700 bg-gray-50 px-2 py-1 rounded-md">
                    <FaThumbsUp className="text-indigo-600" /> {complaint.upvote_count}
                </div>
            </div>
        </div>
    );
}
