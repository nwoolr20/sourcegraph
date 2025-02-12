<svelte:options immutable />

<script lang="ts">
    import Icon from '$lib/Icon.svelte'
    import { mdiAccount } from '@mdi/js'

    import SearchResult from './SearchResult.svelte'
    import { getSearchResultsContext } from './SearchResults.svelte'
    import { getOwnerDisplayName, getOwnerMatchURL, buildSearchURLQueryForOwner } from '$lib/search/results'
    import UserAvatar from '$lib/UserAvatar.svelte'
    import type { PersonMatch } from '$lib/shared'

    export let result: PersonMatch

    const queryState = getSearchResultsContext().queryState

    $: ownerURL = getOwnerMatchURL(result)
    $: displayName = getOwnerDisplayName(result)
    $: fileSearchQueryParams = buildSearchURLQueryForOwner($queryState, result)
</script>

<SearchResult>
    <UserAvatar slot="icon" user={{ ...result.user, displayName }} />
    <div slot="title">
        &nbsp;
        {#if ownerURL}
            <a data-sveltekit-reload href={ownerURL}>{displayName}</a>
        {:else}
            {displayName}
        {/if}
        <span class="info">
            <Icon aria-label="Forked repository" svgPath={mdiAccount} inline />
            <small>Owner (person)</small>
        </span>
    </div>
    {#if fileSearchQueryParams}
        <p class="p-2 m-0">
            <a data-sveltekit-preload-data="tap" href="/search?{fileSearchQueryParams}">Show files</a>
        </p>
    {/if}
    {#if !result.user}
        <p class="p-2 m-0">
            <small class="font-italic"> This owner is not associated with any Sourcegraph user </small>
        </p>
    {/if}
</SearchResult>

<style lang="scss">
    .info {
        border-left: 1px solid var(--border-color);
        margin-left: 0.5rem;
        padding-left: 0.5rem;
    }
</style>
