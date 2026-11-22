import tailwind from "bun-plugin-tailwind";

const result = await Bun.build({
	entrypoints: ["./src/cli.ts"],
	compile: { outfile: "./dist/reflex" },
	minify: true,
	plugins: [tailwind],
});

if (!result.success) {
	for (const log of result.logs) console.error(log);
	process.exit(1);
}
console.log("built dist/reflex");
