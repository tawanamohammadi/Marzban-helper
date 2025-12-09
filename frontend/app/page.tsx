import Link from "next/link";

export default function Home() {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24 relative overflow-hidden">
            {/* Background Blobs */}
            <div className="absolute top-0 left-0 w-96 h-96 bg-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 -translate-x-1/2 -translate-y-1/2 animate-blob"></div>
            <div className="absolute top-0 right-0 w-96 h-96 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 translate-x-1/2 -translate-y-1/2 animate-blob animation-delay-2000"></div>

            <div className="z-10 text-center space-y-8 glass-panel p-12 max-w-2xl w-full">
                <h1 className="text-5xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-400">
                    Marzban Auxiliary
                </h1>
                <p className="text-gray-300 text-lg">
                    Advanced Panel for Resellers and Users
                </p>

                <div className="flex justify-center gap-6">
                    <Link href="/login" className="btn-primary">
                        Reseller Login
                    </Link>
                    <Link href="/user/login" className="px-6 py-2 rounded-lg border border-white/10 hover:bg-white/5 transition">
                        User Portal
                    </Link>
                </div>
            </div>
        </main>
    );
}
