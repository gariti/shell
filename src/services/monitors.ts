import { GObject, execAsync, property, register } from "astal";
import AstalHyprland from "gi://AstalHyprland";

@register({ GTypeName: "Monitor" })
export class Monitor extends GObject.Object {
    readonly monitor: AstalHyprland.Monitor;
    readonly width: number;
    readonly height: number;
    readonly id: number;
    readonly serial: string;
    readonly name: string;
    readonly description: string;

    @property(AstalHyprland.Workspace)
    get activeWorkspace() {
        return this.monitor.activeWorkspace;
    }

    isDdc: boolean = false;
    busNum?: string;

    readonly #subs: JSX.Element[] = [];

    #brightness: number = 0;
    #destroyed: boolean = false;

    @property(Boolean)
    get destroyed() {
        return this.#destroyed;
    }

    @property(Number)
    get brightness() {
        return this.#brightness;
    }

    set brightness(value) {
        value = Math.min(1, Math.max(0, value));

        this.#brightness = value;
        this.notify("brightness");
        execAsync(
            this.isDdc
                ? `ddcutil -b ${this.busNum} setvcp 10 ${Math.round(value * 100)}`
                : `brightnessctl set ${Math.floor(value * 100)}% -q`
        ).catch(console.error);
    }

    addSub(sub: JSX.Element) {
        this.#subs.push(sub);
    }

    destroy() {
        this.#destroyed = true;
        for (const sub of this.#subs) sub.destroy();
    }

    constructor(monitor: AstalHyprland.Monitor) {
        super();

        this.monitor = monitor;
        this.width = monitor.width;
        this.height = monitor.height;
        this.id = monitor.id;
        this.serial = monitor.serial;
        this.name = monitor.name;
        this.description = monitor.description;

        monitor.connect("notify::active-workspace", () => this.notify("active-workspace"));
        monitor.connect("removed", () => this.destroy());

        execAsync("ddcutil detect --brief")
            .then(out => {
                this.isDdc = out.split("\n\n").some(display => {
                    if (!/^Display \d+/.test(display)) return false;
                    const lines = display.split("\n").map(l => l.trimStart());
                    if (lines.find(l => l.startsWith("Monitor:"))?.split(":")[3] !== monitor.serial) return false;
                    this.busNum = lines.find(l => l.startsWith("I2C bus:"))?.split("/dev/i2c-")[1];
                    return this.busNum !== undefined;
                });
            })
            .catch(() => (this.isDdc = false))
            .finally(async () => {
                if (this.isDdc) {
                    const info = (await execAsync(`ddcutil -b ${this.busNum} getvcp 10 --brief`)).split(" ");
                    this.#brightness = Number(info[3]) / Number(info[4]);
                } else
                    this.#brightness =
                        Number(await execAsync("brightnessctl get")) / Number(await execAsync("brightnessctl max"));
            });
    }
}

@register({ GTypeName: "Monitors" })
export default class Monitors extends GObject.Object {
    static instance: Monitors;
    static get_default() {
        if (!this.instance) this.instance = new Monitors();

        return this.instance;
    }

    readonly #map: Map<number, Monitor> = new Map();
    readonly #subs: ((monitor: Monitor) => void)[] = [];

    @property(Object)
    get map() {
        return this.#map;
    }

    @property(Object)
    get list() {
        return Array.from(this.#map.values());
    }

    @property(Monitor)
    get active() {
        return this.#map.get(AstalHyprland.get_default().focusedMonitor.id)!;
    }

    #notify() {
        this.notify("map");
        this.notify("list");
    }

    applyAll(fn: (monitor: Monitor) => JSX.Element) {
        const subFn = (monitor: Monitor) => monitor.addSub(fn(monitor));
        for (const monitor of this.#map.values()) subFn(monitor);
        this.#subs.push(subFn);
    }

    constructor() {
        super();

        const hyprland = AstalHyprland.get_default();

        for (const monitor of hyprland.monitors) this.#map.set(monitor.id, new Monitor(monitor));
        if (this.#map.size > 0) this.#notify();

        hyprland.connect("monitor-added", (_, monitor) => {
            const mon = new Monitor(monitor);
            this.#map.set(monitor.id, mon);
            this.#notify();
            this.#subs.forEach(fn => fn(mon));
        });
        hyprland.connect("monitor-removed", (_, id) => this.#map.delete(id) && this.#notify());

        hyprland.connect("notify::focused-monitor", () => this.notify("active"));
    }
}
