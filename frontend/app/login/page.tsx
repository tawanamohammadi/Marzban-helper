"use client";
import { useState } from "react";
import axios from "axios";
import { useRouter } from "next/navigation";

export default function LoginPage() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const router = useRouter();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const formData = new FormData();
            formData.append("username", username);
            formData.append("password", password);

            // In production, use environment variable for backend URL
            const response = await axios.post("http://YOUR_SERVER_IP:7000/api/auth/token", formData);

            const { access_token } = response.data;
            localStorage.setItem("token", access_token);

            router.push("/dashboard");
        } catch (err: any) {
            setError("Invalid credentials or server error");
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center p-4">
            <form onSubmit={handleLogin} className="glass-panel p-8 w-full max-w-md space-y-6">
                <h2 className="text-2xl font-bold text-center">Reseller Login</h2>

                {error && <div className="text-red-400 text-sm text-center">{error}</div>}

                <div className="space-y-2">
                    <label className="text-sm text-gray-400">Username</label>
                    <input
                        type="text"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="glass-input w-full"
                        placeholder="Enter username"
                    />
                </div>

                <div className="space-y-2">
                    <label className="text-sm text-gray-400">Password</label>
                    <input
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="glass-input w-full"
                        placeholder="Enter password"
                    />
                </div>

                <button type="submit" className="btn-primary w-full">
                    Sign In
                </button>
            </form>
        </div>
    );
}
