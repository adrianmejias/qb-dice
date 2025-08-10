import { createApp, ref, computed, onMounted } from 'vue';
import '../css/app.css';

const appState = {
	visible: ref(false),
	startedBy: ref(''),
	scoreboard: ref([]),
	turnIndex: ref(1),
	youCitizenId: ref(null),
};

const App = {
	setup() {
		const sortedBoard = computed(() => appState.scoreboard.value);
		const yourTurn = computed(() => {
			if (!appState.youCitizenId.value) return false;
			const player = sortedBoard.value[appState.turnIndex.value - 1];
			return player && player.citizenid === appState.youCitizenId.value;
		});

		const roll = () => {
			fetch(`https://qb-dice/roll`, { method: 'POST' });
		};

		onMounted(() => {
			window.addEventListener('message', (e) => {
				const data = e.data || {};
				if (data.action === 'dice:update') {
					appState.startedBy.value = data.startedBy;
					appState.scoreboard.value = data.board || [];
					appState.turnIndex.value = data.turnIndex || 1;
					appState.youCitizenId.value = data.youCitizenId;
					appState.visible.value = true;
				} else if (data.action === 'dice:hide') {
					appState.visible.value = false;
				}
			});
		});

		return { ...appState, sortedBoard, yourTurn, roll };
	},
	template: `
	<div v-if="visible" class="w-screen h-screen pointer-events-none select-none flex items-start justify-center p-6 text-white font-sans">
		<div class="bg-neutral-900/80 backdrop-blur-sm rounded-lg shadow-lg w-full max-w-md p-4 pointer-events-auto">
			<div class="flex items-center justify-between mb-2">
				<h1 class="text-lg font-semibold">Dice Game <span class="text-xs font-normal text-neutral-400 ml-1">Started by {{ startedBy || 'Unknown' }}</span></h1>
				<button @click="visible=false" class="text-neutral-400 hover:text-white transition" title="Hide">×</button>
			</div>
			<div class="space-y-1">
				<div v-for="(p,i) in sortedBoard" :key="p.citizenid" :class="['flex items-center justify-between py-1.5 px-2 rounded', i+1===turnIndex ? 'bg-amber-600/30 ring-1 ring-amber-500/40' : 'bg-neutral-700/30']">
					<div class="flex flex-col">
						<span class="text-sm font-medium" :class="{'text-amber-300': i+1===turnIndex}">{{ i+1===turnIndex ? '→ ' : ''}}{{ p.name }}</span>
						<span class="text-[11px] text-neutral-400">Last: {{ p.lastRoll || '-' }}</span>
					</div>
					<span class="text-base font-semibold tabular-nums">{{ p.score }}</span>
				</div>
			</div>
			<div class="mt-3 flex items-center justify-between text-xs text-neutral-400">
				<span v-if="yourTurn" class="text-emerald-300 font-medium">Your turn - Roll!</span>
				<span v-else>Waiting for turn...</span>
				<button @click="roll" :disabled="!yourTurn" class="px-3 py-1 rounded bg-emerald-600 disabled:bg-neutral-600 disabled:cursor-not-allowed text-white text-xs font-semibold hover:bg-emerald-500 transition">Roll</button>
			</div>
			<p class="mt-2 text-[10px] text-neutral-500">Press E (in-world) or use this panel. Leaving the area removes you.</p>
		</div>
	</div>`
};

createApp(App).mount('#app');
