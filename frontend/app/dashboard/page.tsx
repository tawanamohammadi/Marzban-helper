"use client";
import { useEffect, useState } from "react";
import axios from "axios";
import { useRouter } from "next/navigation";

interface SystemStats {
    version: string;
    total_users: number;
    active_users: number;
    mem_total: number;
    mem_used: number;
    cpu_usage: number;
}

interface ResellerStats {
    username: string;
    quota: number;
    used_by_my_users: number;
}

interface DashboardData {
    reseller: ResellerStats;
    system: SystemStats;
}

export default function DashboardPage() {
    const [data, setData] = useState<DashboardData | null>(null);
    const [loading, setLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchData = async () => {
            const token = localStorage.getItem("token");
            if (!token) {
                router.push("/login");
                return;
            }

            try {
                // Fetch from our new aggregated endpoint
                // NOTE: Make sure to use the correct Port (7000)
                const res = await axios.get("http://YOUR_SERVER_IP:7000/api/admin/dashboard-stats", {
                    headers: { Authorization: `Bearer ${token}` }
                });
                setData(res.data);
            } catch (err) {
                console.error("Failed to fetch dashboard data", err);
                // Optional: Token expired?
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [router]);

    if (loading) return <div className="text-center p-10 text-white">Loading System Data...</div>;
    if (!data) return null;

    // Helpers
    const formatBytes = (bytes: number) => (bytes / (1024 ** 3)).toFixed(2) + " GB";
    const memPercent = ((data.system.mem_used / data.system.mem_total) * 100).toFixed(1);

    return (
        <div className="p-8 space-y-8">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-400">
                        Overview
                    </h1>
                    <p className="text-gray-400 text-sm">Marzban Version: {data.system.version}</p>
                </div>

                <button
                    onClick={() => { localStorage.removeItem("token"); router.push("/login"); }}
                    className="px-4 py-2 border border-white/10 rounded hover:bg-white/5 text-sm"
                >
                    Logout
                </button>
            </div>

            {/* Row 1: Real System Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div className="glass-panel p-6 border-b-4 border-blue-500">
                    <h3 className="text-gray-400 text-sm uppercase">Active Users</h3>
                    <p className="text-3xl font-bold mt-2">{data.system.active_users} <span className="text-sm text-gray-500">/ {data.system.total_users}</span></p>
                </div>

                <div className="glass-panel p-6 border-b-4 border-green-500">
                    <h3 className="text-gray-400 text-sm uppercase">CPU Usage</h3>
                    <p className="text-3xl font-bold mt-2">{data.system.cpu_usage}%</p>
                </div>

                <div className="glass-panel p-6 border-b-4 border-yellow-500">
                    <h3 className="text-gray-400 text-sm uppercase">Memory</h3>
                    <p className="text-3xl font-bold mt-2">{memPercent}%</p>
                    <p className="text-xs text-gray-500 mt-1">{formatBytes(data.system.mem_used)} / {formatBytes(data.system.mem_total)}</p>
                </div>

                <div className="glass-panel p-6 border-b-4 border-purple-500">
                    <h3 className="text-gray-400 text-sm uppercase">My Quota</h3>
                    <p className="text-3xl font-bold mt-2">{formatBytes(data.reseller.quota)}</p>
                </div>
            </div>

            {/* Row 2: User Management Placeholder */}
            <div className="glass-panel p-6 min-h-[300px]">
                <h2 className="text-xl font-bold mb-4">User Management</h2>
                <p className="text-gray-400">User table integrated with Marzban API will appear here.</p>
            </div>
        </div>
    );
}
