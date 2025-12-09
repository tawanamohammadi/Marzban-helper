import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
    title: "Marzban Auxiliary Panel",
    description: "Advanced management for Marzban",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en">
            <body className="antialiased">{children}</body>
        </html>
    );
}
