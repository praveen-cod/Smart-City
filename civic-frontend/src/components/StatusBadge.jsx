export default function StatusBadge({ status }) {
    const colors = {
        submitted: 'bg-blue-100 text-blue-800',
        in_progress: 'bg-yellow-100 text-yellow-800',
        resolved: 'bg-green-100 text-green-800',
        rejected: 'bg-red-100 text-red-800'
    };
    const color = colors[status] || 'bg-gray-100 text-gray-800';
    return (
        <span className={`px-2 py-1 rounded-full text-xs font-bold uppercase tracking-wider ${color}`}>
            {status.replace('_', ' ')}
        </span>
    );
}
