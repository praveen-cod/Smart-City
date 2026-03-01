export default function SeverityBadge({ severity }) {
    const colors = {
        low: 'bg-green-100 text-green-800',
        moderate: 'bg-yellow-100 text-yellow-800',
        critical: 'bg-red-100 text-red-800'
    };
    const color = colors[severity] || 'bg-gray-100 text-gray-800';
    return (
        <span className={`px-2 py-1 rounded-full text-xs font-bold uppercase tracking-wider ${color}`}>
            {severity}
        </span>
    );
}
