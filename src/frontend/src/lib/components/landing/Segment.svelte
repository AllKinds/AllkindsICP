<div class="flex flex-col lg:flex-row items-start justify-between mt-16 md:py-12 lg:max-h-screen ">
	<!-- segment left column -->
	<div class="flex flex-col gap-1 md:gap-3 xl:max-w-[70%]">
		{#if $$slots.title} <slot name="title" /> {/if}
		{#if $$slots.text1} <slot name="text1" /> {/if}
		{#if $$slots.text2} <slot name="text2" /> {/if}
		{#if $$slots.extra} <slot name="extra" /> {/if}
	</div>

	<!-- segment right column -->
	{#if $$slots.img}
		<div class="flex self-center justify-center">
			<slot name="img" />
		</div>
	{/if}
</div>
