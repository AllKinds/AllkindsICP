<div class="flex flex-col md:flex-row items-start justify-start py-6 md:py-24">
	<!-- segment left column -->
	<div class="flex flex-col gap-1 md:gap-3 xl:max-w-[70%]">
		{#if $$slots.title} <slot name="title" /> {/if}
		{#if $$slots.text1} <slot name="text1" /> {/if}
		{#if $$slots.text2} <slot name="text2" /> {/if}
		{#if $$slots.extra} <slot name="extra" /> {/if}
	</div>

	<!-- segment right column -->

	{#if $$slots.img}
		<div class="flex self-center justify-center md:min-w-fit">
			<slot name="img" />
		</div>
	{/if}
</div>
